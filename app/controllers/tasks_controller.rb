class TasksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_task, only: [:show, :edit, :update, :destroy, :sms, :empty_log]

  # GET /tasks
  def index
    @tasks = Task.all
    respond_to do |format|
      format.html { render :index }
      format.json { render json: @tasks }
    end
  end

  # GET /tasks/1
  def show
    respond_to do |format|
      format.html { render :show }
      format.json { render json: @task }
    end
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  def create
    @task = Task.new(task_params)

    if @task.save
      respond_to do |format|
        format.html { redirect_to @task, notice: 'Task was successfully created.' }
        format.json { render json: @task, status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1
  def update
    if @task.update(task_params)
      respond_to do |format|
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { render json: @task, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :edit }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: 'Task was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /tasks/1/sms
  def sms
    # twilio account settings: this should go somewhere else, like configatron variables
    twilio_endpoint = "https://api.twilio.com/2008-08-01"
    twilio_accountSid = "ACf143846021ae6e180b73c4bebfc4d2e0"
    twilio_authToken = "faf73f854fca4922d4cb1f9206e0c4fc"
    twilio_phoneNumber = "+14244880161"

    number_to_send_to = @task.assigned_phone

    @twilio_client = Twilio::REST::Client.new twilio_accountSid, twilio_authToken
    body = "Hello #{@task.assigned_name}, are you able for a task on #{I18n.l(@task.deadline)}?"

    # the sending of the message should be done through a delayed job so that the application doesn't hang if the twilio api takes too long
    @sms = @twilio_client.account.sms.messages.create(
      :from => twilio_phoneNumber,
      :to => number_to_send_to,
      :body => body,
      :StatusCallback => twilio_status_url(:task_id => @task.id)
    )

    @task.update_attributes(:state => "waiting_response", :last_message => body, :last_message_sid => '')
    respond_to do |format|
      format.html { redirect_to @task, notice: 'The SMS was sent.' }
      format.json { render json: @task, status: :ok }
    end

  end

  def empty_log
    @task.task_logs.destroy_all
    respond_to do |format|
      format.html { redirect_to @task, notice: 'Task log was successfully cleaned.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def task_params
      params.require(:task).permit(:deadline, :assigned_name, :assigned_phone, :state)
    end
end
