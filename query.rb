module Sql
  class Database
    # Simple mocking database object (create, drop, alter actions needs to be added)
    def execute(query)
      puts query.build_sql
    end 
  end

  class Query
    attr_accessor(
      :select_fields,
      :from_tables,
      :joins,
      :conditions,
      :order            
    )

    def initialize(&blk)
      self.joins = {}
      instance_eval(&blk)
    end
    
    def select(*fields)
      self.select_fields = fields
    end

    def from(*tables)
      self.from_tables = tables
    end

    def join(table)
      @join_table = table
    end

    def on(conditions)
      if @join_table
        self.joins[@join_table] = conditions
        @join_table = nil
      else
        raise "Unexpected ON"
      end
    end

    def where(conditions)
      self.conditions = conditions
    end

    def order_by(*fields)
      self.order = fields
    end

    def build_sql
      unless @sql
        @sql = ''
        @sql << "SELECT #{self.select_fields.flatten.join(',')}\n"
        @sql << "FROM #{self.from_tables.join(',')}\n"
        @sql << self.joins.inject('') do |acc, (table, join_conditions)|
          acc << "JOIN #{table} ON #{join_conditions}\n"
          acc
        end
        @sql << "WHERE #{self.conditions}\n" if self.conditions
        @sql << "ORDER BY #{self.order.join(',')}\n" if self.order
        @sql
      else
        @sql
      end
    end

    protected
    def method_missing(id)
      Proxy.new(id.to_s)
    end

    class Proxy
      attr_accessor :text, :parent

      def initialize(text)
        self.text = text
      end
      
      METH_OP_MAP = {
        '==' => '=',
        '>' => '>',
        '<' => '<',
        '<=>' => '<>',
        '&' => 'AND',
        '|' => 'OR',
        'like' => 'LIKE'
      }

      METH_OP_MAP.each_pair do |meth, op|
        define_method meth do |value|
          Proxy.new("#{self.text} #{op} #{quotize_value(value)}")
        end
      end

      def in(*values)
        values = values.map { |value| quotize_value(value) }.join(',')
        Proxy.new("#{self.text} IN(#{values})")
      end

      def g
        self.text = "(#{self.text})"
        self
      end

      def method_missing(id)
        Proxy.new("#{self.text}.#{id}")
      end

      def to_s
        self.text
      end

      protected
      def quotize_value(value)
        if [String, Symbol].include?(value.class)
          "'#{value}'"
        else
          value
        end
      end
    end
  end
end

query = Sql::Query.new do
  select table1.*, table2.field13
  from table1
  #join table2
  #on table1.field10 == table2.field10
  where ((table1.field1.like('asd')) | (table2.field2 <=> 2)).g & (field3.in(1, 2, 3))
  #order_by field1, field2
end

db = Sql::Database.new
db.execute(query)