module Toolbox
  class MonstersController < ApplicationController
    def index
        @roles=[
            ["Artillery",1],
            ["Brute", 2],
            ["Controller", 3],
            ["Lurker", 4],
            ["Skirmisher", 5],
            ["Soldier", 6]
        ]
    end
  end
end
