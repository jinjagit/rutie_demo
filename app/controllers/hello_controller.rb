class HelloController < ApplicationController
  def hello
    @app_config = AppConfig.first

    if @app_config.rust_enabled
      @hello = RustLib.hello_world
    else
      @hello = "Ruby says 'Hi!'"
    end
  end
end