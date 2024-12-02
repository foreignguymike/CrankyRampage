class Button
  
  attr_accessor :text

  def initialize text, x, y, w, h, &callback
    super()
    @text = text
    @x = x
    @y = y
    @w = w
    @h = h
    @callback = callback
    @hover = false
  end

  def check_mouse mx, my
    @hover = mx >= @x - @w / 2 && mx <= @x + @w / 2 && my >= @y - @h / 2 && my <= @y + @h / 2
  end

  def click
    @callback.call if @callback && @hover
  end

  def render args, cam
    cam.render_text args, @text, "fonts/m5x7.ttf", 12.66666, @x, @y, 255, 255, 255, 255, 1, 1
    cam.render_box args, @x, @y, @w, @h, 255, 255, 255, 128 if @hover
  end
end