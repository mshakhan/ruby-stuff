#
# Simple imitation of ActiveRecord::Base behaivour
#
 
class Model
  attr_accessor :attributes
 
  # Sets the collection of valid model attributes
  # e.g
  # class MyModel < Model
  #   valid_attributes :attr1, :attr2
  # end
  #
  # m1 = Model1.new
  # m1.attr1 = 10 # => OK
  # a2 = m1.attr2 # => OK
  # m1.attr3 = 0 # => raises NameError
  def self.valid_attributes(*attributes)
    @@valid_attributes = attributes
  end
 
  def initialize(attributes = {})
    @attributes = attributes
  end
 
  alias_method :__method_missing__, :method_missing
  def method_missing(id, value=nil)
    name = id.to_s
    is_setter = name.sub!(/=/, '')
    name = name.to_sym
    if @@valid_attributes
      __method_missing__(id) unless @@valid_attributes.include? name
    end
    # simple 'caching'
    Model.class_eval <<METH
def #{id}#{'(v)' if is_setter}
  @attributes[:#{name}]#{ ' = v' if is_setter }
end
METH
    if is_setter
      @attributes[name] = value
    else
      @attributes[name]
    end
  end
 
  def inspect
    attrs = @attributes.inject('') do |dump, attr|
      dump << "#{attr.first} = #{attr.last} "
    end
    "#<#{self.class.name}:0x#{self.object_id.to_s(16)} #{attrs}>"
  end
end
 
m = Model.new(:a => 1)
puts m.inspect