class Admin::PriceBookItemsController < Admin::BaseController
  before_action :set_price_book_item, only: [ :edit, :update, :destroy ]

  def index
    @price_book_items = Current.company.price_book_items.order(:category, :name)
  end

  def new
    @price_book_item = Current.company.price_book_items.build
  end

  def create
    @price_book_item = Current.company.price_book_items.build(price_book_item_params)
    if @price_book_item.save
      redirect_to admin_price_book_items_path, notice: "Price book item created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @price_book_item.update(price_book_item_params)
      redirect_to admin_price_book_items_path, notice: "Price book item updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @price_book_item.destroy
    redirect_to admin_price_book_items_path, notice: "Price book item deleted."
  end

  private

  def set_price_book_item
    @price_book_item = Current.company.price_book_items.find(params[:id])
  end

  def price_book_item_params
    params.require(:price_book_item).permit(:name, :category, :unit_price_cents, :taxable, :active, :lock_policy)
  end
end
