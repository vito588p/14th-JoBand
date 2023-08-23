# frozen_string_literal: true

class BandsController < ApplicationController
  before_action :set_band, only: %i[show edit update]

  def index
    @b = Band.ransack(params[:q])
    @bands = @b.result(distinct: true)
  end

  def show; end

  def new
    @band = Band.new
  end

  def create
    @band = Band.new(band_params)
    if @band.save
      BandMember.create(user: current_user, band: @band, band_role: :leader)
      redirect_to band_path(@band), notice: '成功創立樂團'
    else
      render :new, notice: '失敗'
    end
  end

  def edit; end

  def update
    if @band.update(band_params)
      redirect_to band_path(@band), notice: '更新成功'
    else
      render :edit, notice: '失敗'
    end
  end

  private

  def band_params
    params.require(:band).permit(:name, :content, :area, :state, :founded_at, :avatar, :music, :video, :banner,
                                 style_ids: [])
  end
end
