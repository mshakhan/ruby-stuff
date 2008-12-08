=begin
Sql query builing DSL
E.g:
:f1.eq(3).or(:f2.ne(4))
# => f1 = 3 or f2 != 4
:f1.eq(3).and(:f2.eq(4).or(:f2.eq(5)))
# => f1 = 3 and (f2 = 4 or f2 = 5)
:f1.eq(3).and(:f2.eq(4)).or(:f2.eq(5))
# => f1 = 3 and (f2 = 4) or f2 = 5
:f1.eq(3).and(:f2.eq(4)).or(:f2.eq(5)).and(:f4.like('%hello%')).or(:f5.in('1', '2', '3'))
# => f1 = 3 and (f2 = 4) or f2 = 5 and (f4 like '%hello%') or f5 in ('1','2','3')
=end

# core extensions
class Symbol
  def eq(value)
    Condition.new(:eq, self, value)
  end

  def ne(value)
    Condition.new(:ne, self, value)
  end

  def like(value)
    Condition.new(:like, self, value.quotize)
  end

  def in(*values)
    Condition.new(:in, self, "(#{values.collect{|v| v.quotize }.join(',')})")
  end
end

class Object
  def quotize
    return self unless self.is_a? String
    "'#{self}'"
  end
end
# end of core extensions

# Elementary condition like field1 = 1
# Includes collection of child conditions
class Condition
  attr_reader :type, :field, :value, :children
  attr_accessor :op

  def initialize(type, field, value, op = nil)
    @type, @field, @value, @op = type, field, value, op
    @children = []
  end

  def and(cond)
    cond.op = :and
    @children << cond
    self
  end

  def or(cond)
    cond.op = :or
    @children << cond
    self
  end

  def build
    SqlBuilder.new(self).build
  end
  alias_method :to_s, :build
end

# Buils sql WHERE clause from conditions tree
class SqlBuilder
  def initialize(cond)
    @cond = cond
  end

  def build
    dump = "#{@cond.field} #{type_to_sym(@cond.type)} #{@cond.value}"
    @cond.children.inject(dump) do |dmp, cond|
      dump << append_op(cond)
    end.strip
  end

  private
  def type_to_sym(type)
    # TODO: in constant
    {
      :eq => '=',
      :ne => '!=',
      :in => 'in',
      :like => 'like'
    }[type]
  end

  def append_op(cond)
    case cond.op
    when :or
      " or #{cond.build}"
    when :and
      " and (#{cond.build})"
    end
  end
end
