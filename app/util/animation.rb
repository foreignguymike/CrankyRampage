class Animation

  attr_reader :play_count, :index

  def initialize count, interval
    @count = count
    @interval = interval
    @index = 0
    @ticks = 0
    @play_count = 0
  end

  def tick
    @ticks += 1
    if @ticks >= @interval
      @ticks -= @interval
      @index += 1
      if @index >= @count
        @index = 0
        @play_count += 1
      end
    end
  end

end