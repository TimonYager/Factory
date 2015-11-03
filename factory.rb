class Factory
  include Enumerable

  def self.new(*params, &block)
    class_name = params.shift if params[0].is_a?(String) && params[0][0] == params[0][0].upcase
    
    raise ArgumentError, "ArgumentError: wrong number of arguments (0 for 1+)" if params.size == 0

    type = Class.new do
      define_method :initialize do |*values|
        @values = values
        raise ArgumentError, "ArgumentError: struct size differs" if @values.size != params.size
        params.each_with_index do |param, i|
          instance_variable_set("@#{param}", @values[i])
        end
      end

      params.each_with_index do |param, i|
        define_method "#{param}=".to_sym do |value| 
          instance_variable_set("@#{param}", value) 
        end

        define_method param.to_sym do
          instance_variable_get("@#{param}")
        end
      end

      define_method :== do |other|
        self.class == other.class && @values == other.values
      end 
      alias :eql? :==

      define_method :[] do |i|
        send("#{params[index_converter(i)]}")
      end

      define_method :[]= do |i, value|
        send("#{params[index_converter(i)]}=", value)
      end

      define_method :each do |&block|
        if block
          @values.each(&block)
        else
          @values.to_enum
        end
      end

      define_method :each_pair do |&block|
        hash = self.to_h
        if block
          hash.each_pair(&block)
        else
          hash.to_enum
        end
      end

      define_method :hash do
        h = Hash.new(0)
        params.each_with_index { |param, i| h[param] = @values[i] }
        h.hash
      end

      define_method :inspect do
        string = "#<factory #{self.class}"
        params.each_with_index { |param, i| string += " #{param}=\"#{@values[i]}\"," }
        string[0..-2] + ">"
      end
      alias :to_s :inspect

      define_method :length do
        params.size
      end
      alias :size :length

      define_method :members do
        params
      end

      define_method :select do |&block|
        if block
          @values.select(&block)
        else
          @values.to_enum
        end         
      end

      define_method :to_a do 
        @values
      end
      alias :values :to_a

      define_method :to_h do
        hash = Hash.new(0)
        params.each_with_index { |param, i| hash[param] = @values[i] }
        hash
      end

      define_method :values_at do |*selectors|
        values = Array.new
        selectors.each do |selector|
          if selector.is_a?(Range)
            selector.each { |sel| values << @values[index_converter(sel)]}
          else
            values << @values[index_converter(selector)]
          end
        end
        values
      end

      class_eval(&block) if block

      private

      define_method :index_converter do |i|
        type = i.class.to_s
        case type
        when "Fixnum"
          raise IndexError, "offset #{i} too large for struct(size:#{params.size})" if i > params.size - 1
          i
        when "Symbol"
          raise NameError, "no member '#{i}' in struct" unless params.include?(i)
          params.index { |param| param == i }
        when "String"
          raise NameError, "no member '#{i}' in struct" unless params.include?(i.to_sym)
          params.index { |param| param == i.to_sym }
        else 
          raise ArgumentError
        end
      end
    
    end

    Kernel.const_set(class_name, type) if class_name
    type

  end
end
