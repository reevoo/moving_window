class MovingWindow

  def self.scope(column = :created_at, &block)
    arel = block.binding.eval("self")
    instance = new(&block)

    Procxy.new(instance, arel, column)
  end

  def initialize(&block)
    @block = block
  end

  def filter(scope, params = {})
    column, qualifier = parse(params)
    scope.where(["#{column} #{qualifier} ? and ?", *timestamps])
  end

  private
  def parse(params)
    column    = params[:column] || :created_at
    qualifier = params[:negate] ? 'not between' : 'between'

    [column, qualifier]
  end

  def timestamps
    from, to = @block.call
    to ||= Time.now
    [from, to].sort
  end

  class Procxy < Struct.new(:instance, :arel, :column)
    def call
      instance.filter(arel, :column => column, :negate => @not)
    end

    def not
      @not = !@not
      self
    end
  end

end
