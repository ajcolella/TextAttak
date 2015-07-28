class Attak < ActiveRecord::Base
  has_many :texts
  has_many :images
end