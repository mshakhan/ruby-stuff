class XmlDoc
  def initialize(out=$stdout, &blk)
    @out = out
    instance_eval(&blk) if blk
  end
  
  def method_missing(name, attrs={}, &blk)
    out "<#{name}#{self.class.attrs_to_xml attrs}>"
    instance_eval(&blk) if blk
    out "</#{name}>"
  end
    
  def _(text=nil)
    out text
  end
  
  def out(text)
    @out << "#{text}\n"
  end
  
  def self.attrs_to_xml(attrs)
    attrs.inject('') do |xml, (k, v)|
      xml << " #{k}='#{v}'"
    end
  end
end

xml = ''
XmlDoc.new(xml) {
  html {
    head {
      title {
        _ 'hello from ruby'
      }
    }
    body {
      _ 'hello'
      div(:class => 'fuck') {
        _ 'hi!'
      }
    }
  }
}

puts xml