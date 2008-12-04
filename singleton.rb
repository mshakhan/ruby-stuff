#
# Dummy singleton implementation
#
# Singleton is evil =)
#

module Singleton
  def self.append_features(base)
    super
    base.extend(ClassMembers)
    base.class.send :alias_method, :__new__, :new
    base.class.send :private, :__new__
  end  

  module ClassMembers
    def new
      @@inst ||= self.send :__new__
    end 
  end
end


class C
  include Singleton

  attr_accessor :state
  def initialize
    puts "class #{self.class} constructor. state = #{state}"
  end
end

C.new
C.new # => ?