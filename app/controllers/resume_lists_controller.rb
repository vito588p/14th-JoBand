# frozen_string_literal: true

class ResumeListsController < ApplicationController
  before_action :set_resume_list, only: %i[show edit update destroy approve reject]
  before_action :set_recruit, only: %i[new create]

  def show
    authorize @resume_list
    @comment = Comment.new
    @comments = @resume_list.comments.order(created_at: :desc)
  end

  def new
    @resume_list = ResumeList.new(recruit: @recruit)
    authorize @resume_list
  end

  def create
    @resume_list = @recruit.resume_lists.build(resume_list_params)
    authorize @resume_list
    if @resume_list.save
      redirect_to resume_list_path(@resume_list), notice: '申請成功'
    else
      render :new
    end
  end

  def edit
    authorize @resume_list
    @recruit = @resume_list.recruit
  end

  def update
    authorize @resume_list
    if @resume_list.update(resume_list_params)
      redirect_to resume_list_path(@resume_list), notice: '更新成功'
    else
      render :edit
    end
  end

  def approve
    authorize @resume_list
    @recruit = @resume_list.recruit
    @band = @recruit.band
    @role = @resume_list.role
    @user = @resume_list.user
    new_band_member = @band.band_members.new(user: @user, identity: :member, role: @role)
    if new_band_member.save
      @resume_list.update(status: :approved)
      redirect_to recruit_path(@recruit), notice: '已加入樂團'
    else
      render :show, alert: '加入失敗'
    end
  end

  def reject
    authorize @resume_list
    if @resume_list.update(status: :rejected)
      redirect_to recruit_path(@resume_list.recruit), notice: '已拒絕申請'
    else
      reder resume_list_path(@resume_list), alert: '操作失敗'
    end
  end

  private

  def set_recruit
    @recruit = Recruit.find(params[:recruit_id])
  end

  def set_resume_list
    @resume_list = ResumeList.find(params[:id])
  end

  def resume_list_params
    params.require(:resume_list).permit(:user_id, :description, :role, :status)
  end
end
