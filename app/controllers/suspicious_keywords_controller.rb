class SuspiciousKeywordsController < ApplicationController
  before_action :set_suspicious_keyword, only: [:show, :edit, :update, :destroy]

  # GET /suspicious_keywords
  # GET /suspicious_keywords.json
  def index
    @suspicious_keywords = SuspiciousKeyword.all
  end

  # GET /suspicious_keywords/1
  # GET /suspicious_keywords/1.json
  def show
  end

  # GET /suspicious_keywords/new
  def new
    @suspicious_keyword = SuspiciousKeyword.new
  end

  # GET /suspicious_keywords/1/edit
  def edit
  end

  # POST /suspicious_keywords
  # POST /suspicious_keywords.json
  def create
    @suspicious_keyword = SuspiciousKeyword.new(suspicious_keyword_params)

    respond_to do |format|
      if @suspicious_keyword.save
        format.html { redirect_to @suspicious_keyword, notice: 'Suspicious keyword was successfully created.' }
        format.json { render action: 'show', status: :created, location: @suspicious_keyword }
      else
        format.html { render action: 'new' }
        format.json { render json: @suspicious_keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /suspicious_keywords/1
  # PATCH/PUT /suspicious_keywords/1.json
  def update
    respond_to do |format|
      if @suspicious_keyword.update(suspicious_keyword_params)
        format.html { redirect_to @suspicious_keyword, notice: 'Suspicious keyword was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @suspicious_keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /suspicious_keywords/1
  # DELETE /suspicious_keywords/1.json
  def destroy
    @suspicious_keyword.destroy
    respond_to do |format|
      format.html { redirect_to suspicious_keywords_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_suspicious_keyword
      @suspicious_keyword = SuspiciousKeyword.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def suspicious_keyword_params
      params.require(:suspicious_keyword).permit(:keyword)
    end
end
