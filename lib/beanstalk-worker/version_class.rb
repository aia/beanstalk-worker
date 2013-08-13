module BeanStalk
  class Worker
    module Version
      include Comparable
      attr_reader :major, :minor, :patch

      def initialize(str="")
        parse(str)
      end

      def inspect
        "#{@major}.#{@minor}.#{@patch}"
      end

      def to_s
        "#{@major}.#{@minor}.#{@patch}"
      end

      def <=>(v)
        [:major, :minor, :patch].each do |method|
          ans = (self.send(method) <=> v.send(method))
          return ans if ans != 0
        end
        0
      end

      def hash
        to_s.hash
      end

      # For hash
      def eql?(other)
        other.is_a?(Version) && self == other
      end

      protected

      def parse(str="")
        @major, @minor, @patch =
          case str.to_s
          when /^(\d+)\.(\d+)\.(\d+)$/
            [ $1.to_i, $2.to_i, $3.to_i ]
          when /^(\d+)\.(\d+)$/
            [ $1.to_i, $2.to_i, 0 ]
          else
            "'#{str.to_s}' does not match 'x.y.z' or 'x.y'"
          end
      end

    end
  end
end
