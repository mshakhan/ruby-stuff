=begin
  Attempt to create a xml markup DSL
  The result should be like that:
  XmlDoc.new do
    html do
      head do
      end
    end
  end
  (without parameter in block)
=end

class XmlNode
  attr_accessor :name, :parent, :children, :attrs, :level
  
  def initialize(name, parent = nil, attrs = {}, level = 0, children = [])
    @name, @parent, @children, @attrs, @level = name, parent, children, attrs, level
    @builder = XmlBuilder.new(self)
    yield self if block_given?
  end

  def method_missing(name, attrs={}, &blk)
    name = name.to_s
    node = XmlNode.new(name, self, attrs, @level + 1, &blk)
    @children << node
    node
  end

  def **(str)
    @children << @builder.text(str)
  end

  def next
    return false unless @parent
    indx = @parent.children.index(self) + 1
    if indx < @parent.children.size
      @parent.children[indx]
    end    
  end

  def prev
    return false unless @parent
    indx = @parent.children.index(self) - 1
    if indx > 0
      @parent.children[indx]
    end        
  end

  def to_s
    @builder.build
  end
end

class XmlBuilder
  def initialize(node)
    @node = node
  end

  def build
    children = @node.children.inject([]) do |arr, node|
      arr << "#{node.to_s}\n"
    end
    "#{level_spaces}<#{@node.name}#{build_attrs}>\n#{children.join}#{level_spaces}</#{@node.name}>"    
  end

  def text(txt)
    "#{level_spaces 1}#{txt}".gsub('<', '&lt;').gsub('>', '&gt;') 
  end 

  private
  def build_attrs
     @node.attrs.inject('') do |str, arg|
      str << " #{arg.first}='#{arg.last}'"
    end     
  end

  def level_spaces(add = 0)
    ' ' * (@node.level + add)
  end
end

class XHtmlDoc <  XmlNode
  def initialize
    super('html')
  end
end

# check this
html = XHtmlDoc.new do |html|
  html.head do |head|
    html.title do |title|
      title ** 'hello from ruby!'
    end
  end
  html.body :align => 'left', :width => '100%' do |body|
    body ** 'header'
      body.div :style => 'width:100%; text-align:center;' do |div|
        div ** 'main content' 
      end
    body ** 'footer'
  end
end

puts html.to_s
