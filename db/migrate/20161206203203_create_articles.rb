class CreateArticles < ActiveRecord::Migration[5.0]
  def change
    create_table :articles do |t|
      t.string :name
      t.text :content
      t.date :published_on

      t.timestamps
    end
  end
end
