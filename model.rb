#
# Simple imitation of ActiveRecord::Base behaivour
#

class Model
  attr_accessor :attributes

  # Sets the collection of valid model attributes
  # e.g 
  # class MyModel < Model
  # 	valid_attributes :attr1, :attr2
  # end
  #
  # m1 = Model1.new
  # m1.attr1 = 10 # => OK
  # a2 = m1.attr2 # => OK
  # m1.attr3 = 0  # => raises NameError
  def self.valid_attributes(*attrs)
    @@valid_attributes = attrs
  end

  def initialize(attrs = {})
    @attributes = attrs
  end

  alias_method :__method_missing__, :method_missing
  def method_missing(id, value = nil)
  # TODO: refactor this shit!
    name = id.to_s
    is_setter = (name =~ /=$/)
    name = name[0..name.size-2] if is_setter
    if @@valid_attributes
      __method_missing__(id) unless @@valid_attributes.include?(name.to_sym)
    end
    # simple 'caching'
    Model.class_eval <<METH
      def #{id}#{'(v)' if is_setter}
        @attributes[:#{name}]#{ ' = v' if is_setter }
      end
METH
    if is_setter
      @attributes[name.to_sym] = value
    else
      @attributes[name.to_sym]
    end
  end

  # pretty view of model attributes
  def inspect
    @attributes.inject('') do |dump, attr|
      dump << "#{attr.first} = #{attr.last}\n"
    end
  end
end

m = Model.new(:a => 1)
puts m.inspect
