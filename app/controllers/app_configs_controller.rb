class AppConfigsController < ApplicationController
  before_action :set_app_config, only: %i[ show edit update destroy ]

  # GET /app_configs or /app_configs.json
  def index
    @app_configs = AppConfig.all
  end

  # GET /app_configs/1 or /app_configs/1.json
  def show
  end

  # GET /app_configs/new
  def new
    @app_config = AppConfig.new
  end

  # GET /app_configs/1/edit
  def edit
  end

  # POST /app_configs or /app_configs.json
  def create
    @app_config = AppConfig.new(app_config_params)

    respond_to do |format|
      if @app_config.save
        format.html { redirect_to app_config_url(@app_config), notice: "App config was successfully created." }
        format.json { render :show, status: :created, location: @app_config }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @app_config.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /app_configs/1 or /app_configs/1.json
  def update
    respond_to do |format|
      if @app_config.update(app_config_params)
        format.html { redirect_to controller: :hello, action: :hello }
        format.json { render :show, status: :ok, location: @app_config }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @app_config.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /app_configs/1 or /app_configs/1.json
  def destroy
    @app_config.destroy

    respond_to do |format|
      format.html { redirect_to app_configs_url, notice: "App config was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_app_config
      @app_config = AppConfig.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def app_config_params
      params.require(:app_config).permit(:rust_enabled)
    end
end
