class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :add_balanced_account, :create_balanced_account]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    respond_to do |format|
      if @user.save
        format.html { redirect_to url_for(:controller => 'users', :action => 'add_balanced_account'), notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user.listing }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  # GET /users/1/add_balanced_account
  def add_balanced_account
    if Rails.env.development?
      flash.now[:notice] = "Use Bank Account #8887776665555 and Routing #321174851 to test the booking system."
    end
  end

  def create_balanced_account
    @user.balanced_customer.add_bank_account(user_params[:bank_account_uri])
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to new_listing_path, notice: 'Bank account was successfully added.' }
        format.json { head :no_content }
      else
        format.html { render action: 'new_balanced_account' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:avatar, :name, :zipcode, :bank_account_uri)
    end

end
