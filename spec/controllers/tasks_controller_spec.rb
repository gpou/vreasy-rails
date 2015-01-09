require 'rails_helper'

RSpec.describe TasksController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # Task. As you add validations to Task, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    { "deadline(1i)" => "2014", "deadline(2i)" => "12", "deadline(3i)" => "29", "deadline(4i)" => "21", "deadline(5i)" => "21", "assigned_name" => "gemma", "assigned_phone" => "+12013454558" }
  }

  let(:invalid_attributes) {
    { "assigned_name" => "gemma" }
  }

  describe "GET index" do
    it "assigns all tasks as @tasks" do
      task = Task.create! valid_attributes
      get :index
      expect(assigns(:tasks)).to eq([task])
    end
  end

  describe "GET new" do
    it "assigns a new task as @task" do
      get :new, {}
      expect(assigns(:task)).to be_a_new(Task)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Task" do
        expect {
          post :create, {:task => valid_attributes}
        }.to change(Task, :count).by(1)
      end

      it "assigns a newly created task as @task" do
        post :create, {:task => valid_attributes}
        expect(assigns(:task)).to be_a(Task)
        expect(assigns(:task)).to be_persisted
      end

      it "redirects to the created task and saves a flash notice" do
        post :create, {:task => valid_attributes}
        expect(response).to redirect_to(Task.last)
        expect(flash[:notice]).to eq('Task was successfully created.')
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved task as @task" do
        post :create, {:task => invalid_attributes}
        expect(assigns(:task)).to be_a_new(Task)
      end

      it "re-renders the 'new' template" do
        post :create, {:task => invalid_attributes}
        expect(response).to render_template("new")
      end
    end
  end
end

RSpec.describe TasksController, :type => :controller do
  include SmsSpec::Helpers
  include SmsSpec::Matchers

  # This should return the minimal set of attributes required to create a valid
  # Task. As you add validations to Task, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    { "deadline(1i)" => "2014", "deadline(2i)" => "12", "deadline(3i)" => "29", "deadline(4i)" => "21", "deadline(5i)" => "21", "assigned_name" => "gemma", "assigned_phone" => "+12013454558" }
  }

  let(:invalid_attributes) {
    { "assigned_name" => "" }
  }

  before(:each) do
    @task = Task.create! valid_attributes
  end

  describe "GET show" do
    it "assigns the requested task as @task" do
      get :show, {:id => @task.id}
      expect(assigns(:task)).to eq(@task)
    end
  end

  describe "GET edit" do
    it "assigns the requested task as @task" do
      get :edit, {:id => @task.id}
      expect(assigns(:task)).to eq(@task)
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) {
        { "assigned_name" => "gemma2" }
      }
      before(:each) do
        put :update, {:id => @task.id, :task => new_attributes}
      end

      it "updates the requested task" do
        @task.reload
        expect(@task.assigned_name).to eq(new_attributes['assigned_name'])
      end

      it "assigns the requested task as @task" do
        expect(assigns(:task)).to eq(@task)
      end

      it "redirects to the task and saves a flash notice" do
        expect(response).to redirect_to(@task)
        expect(flash[:notice]).to eq('Task was successfully updated.')
      end
    end

    describe "with invalid params" do
      before(:each) do
        put :update, {:id => @task.id, :task => invalid_attributes}
      end

      it "assigns the task as @task" do
        expect(assigns(:task)).to eq(@task)
      end

      it "re-renders the 'edit' template" do
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested task" do
      expect {
        delete :destroy, {:id => @task.id}
      }.to change(Task, :count).by(-1)
    end

    it "redirects to the tasks list and saves a flash notice" do
      delete :destroy, {:id => @task.id}
      expect(response).to redirect_to(tasks_url)
      expect(flash[:notice]).to eq('Task was successfully destroyed.')
    end
  end

  describe "GET sms" do
    before(:each) do
      get 'sms', {:id => @task.id }
      @body = "Hello #{@task.assigned_name}, are you able for a task on #{I18n.l(@task.deadline)}?"
    end

    it "sends a text message to the phone number of the task" do
      open_last_text_message_for @task.assigned_phone
      current_text_message.should have_body @body
    end

    it "updates task status and last_message" do
      expect(assigns(:task).state).to eq("waiting_response")
      expect(assigns(:task).last_message).to eq(@body)
    end

    it "redirects to the task and saves a flash notice" do
      expect(response).to redirect_to(@task)
      expect(flash[:notice]).to eq('The SMS was sent.')
    end
  end

  describe "GET empty_log" do
    before(:each) do
      get 'empty_log', {:id => @task.id }
    end

    it "empties the task log" do
      expect(assigns(:task).task_logs.count).to eq(0)
    end

    it "redirects to the task and saves a flash notice" do
      expect(response).to redirect_to(@task)
      expect(flash[:notice]).to eq('Task log was successfully cleaned.')
    end
  end

end
