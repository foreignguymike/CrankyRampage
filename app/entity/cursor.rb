class Cursor < Entity
  def update
    @render_deg -= 3
  end

  def render args, cam
    set_image args, "cursor"
    cam.render args, self
  end
end