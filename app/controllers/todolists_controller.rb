class TodolistsController < ApplicationController
  def new
    @list = List.new
  end

  def create
    list = List.new(list_params)
    list.score = Language.get_data(list_params[:body])
    list.save
    dominant_color = Vision.get_image_data(list.image).values
    list.tags.create(name: dominant_color.map{|i| i.to_s(16).rjust(2, '0') }.join.upcase)
    #tagsには画像のドミナントカラーを代入する(HTMLカラーコードとして使用)
    colors = { "red" => [220, 53, 69], "orange" => [255, 153, 51], "yellow" => [255, 193, 7], "green" => [40, 167, 69], "blue" => [0, 123, 255], "indigo" => [51, 51, 204], "purple" => [153, 51, 255]}
    distance = {}
    colors.each{|key, value|
      r = "#{(value[0] - dominant_color[0])**2}"
      g = "#{(value[1] - dominant_color[1])**2}"
      b = "#{(value[2] - dominant_color[2])**2}"
      distance[key] = "#{((r + g + b).to_i**(1 / 2.0)).round}"
      #ここまででColor differenceのHashを作成
      if key == "purple"
        sorted_dis = distance.sort {|(k1, v1), (k2, v2)| v1.to_i <=> v2.to_i }.to_h
        topcolor = sorted_dis.first.first
        list.tags.update(color: topcolor)
      end
    }
    redirect_to todolist_path(list.id)
  end

  def index
    @lists = List.all
  end

  def show
    @list = List.find(params[:id])
  end

  def edit
    @list = List.find(params[:id])
  end

  def update
    list = List.find(params[:id])
    list.update(list_params)
    redirect_to todolist_path(list.id)
  end

  def destroy
    list = List.find(params[:id])
    list.destroy
    redirect_to todolists_path
  end

  private

  def list_params
    params.require(:list).permit(:title, :body, :image)
  end

end
