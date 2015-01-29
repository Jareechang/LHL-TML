class CreateUsersTable < ActiveRecord::Migration
  def change
  	create_table :users do |t|
  		t.string :first_name
  		t.string :email
  		t.string :password
  		t.string :phone_number
  		t.timestamps
  	end 
  end
end