module CoreRules
  Rulebook = Struct.new(:slug, :name, :active, :stock, :d20_system, :default_dice, :license, keyword_init: true) do
    def active? = active == "true"
    def stock?  = stock  == "true"
    def d20_system? = d20_system == "true"
  end
end
