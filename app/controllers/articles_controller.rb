class ArticlesController < ApplicationController
  http_basic_authenticate_with name: Credential.http_basic_user, password: Credential.http_basic_password,
                               except: [:index, :show]

  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(allowed_params)
    if @article.save
      redirect_to @article, notice: "Created article."
    else
      render :new
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    if @article.update_attributes(allowed_params)
      redirect_to @article, notice: "Updated article."
    else
      render :edit
    end
  end
  
  private
  
  def allowed_params
    params.require(:article).permit(:name, :published_on, :content)
  end
end