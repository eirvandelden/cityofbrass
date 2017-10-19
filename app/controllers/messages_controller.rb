class MessagesController < ApplicationController

  before_action :authenticate_user!
  before_action :check_user_status

  before_action :check_affiliation, only: [:create]
  before_action :set_resident
  before_action :set_message, only: [:show, :edit, :update, :destroy]

  def inbox
    @messages = @resident.messages_received.includes(:sender).search(params[:search]).page(params[:page])
  end

  def sent
    @messages = @resident.messages_sent.includes(:recipient).search(params[:search]).page(params[:page])
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    @message.readingmessage(@resident.id)
  end

  # GET /messages/new
  def new
    @message = @resident.messages_sent.new(recipient_id: params[:affiliate_id])

    if params[:reply_to]
      @reply_to = Message.find_by_id(params[:reply_to])
      unless @reply_to.nil?
        @message.recipient_id = @reply_to.sender_id
        @message.subject = @reply_to.subject
        @message.subject = "RE: #{@reply_to.subject}" unless @message.subject[0,3] == "RE:"
        @message.body = "\n\nOn #{@reply_to.created_at}, #{@reply_to.sender.name} wrote:\n<blockquote>#{@reply_to.body}</blockquote>"
      end
    end

    @message.sender_id = @resident.id
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = @resident.messages_sent.new(message_params)
    respond_to do |format|
      if @message.save
        format.html { redirect_to inbox_path, notice: 'Message has been sent.' }
        format.json { render action: 'show', status: :created, location: @message }
      else
        format.html { render action: 'new' }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to inbox_path, notice: 'Message has been sent.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message.mark_message_deleted(@message.id,@resident.id) unless @message.nil?
    respond_to do |format|
      format.html { redirect_to inbox_path }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resident
      @resident = current_user.resident
      if @resident.nil?
        render template: 'errors/404', layout: 'layouts/application', status: 404
      end
    end

    def set_message
      @message = Message.includes([:sender, :recipient]).find(params[:id])
    end

    def check_affiliation
      unless params[:recipient_id].nil?
        unless Affiliation.are_affiliates(current_user.resident, params[:recipient_id])
          render template: 'errors/403', layout: 'layouts/application', status: 403
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:sender_id, :recipient_id, :sender_deleted, :recipient_deleted, :subject, :body, :read_at)
    end
end
