(function(e){

  $.fn.popbox = function(options){
    var settings = $.extend({
      selector      : this.selector,
      open          : '.openbox',
      box           : '.rollbox',
      arrow         : '.arrow-top',
      arrow_border  : '.arrow-top-border',
      close         : '.close'
    }, options);

    var methods = {
      open: function(event){
        var pop = $(this);
        var box = $('div').find(settings['box']);
        //var box = $(this).parent().find(settings['box']);

        var offset = pop.offset();
        var offsetTop = (offset.top + pop.height())
        var offsetLeft = (offset.left + (pop.width()/2)-4);

        box.find(settings['arrow']).css({'left': box.width()/2 - 7});
        box.find(settings['arrow_border']).css({'left': box.width()/2 - 7});

        if(box.hasClass("right-edge")){
          offsetLeft-100;
        }
        if(box.hasClass("left-edge")){
          offsetLeft+100;
        }

        box.css({'display': 'block', 'top': (offsetTop-132), 'left': (offsetLeft-box.width()/2)});

        $('.rollbox').offscreen({
          smartResize: true,
          rightClass: 'right-edge',
          leftClass: 'left-edge'
        });

      },

      close: function(){
        $(settings['box']).fadeOut("fast");
      }
    };

    $(document).bind('keyup', function(event){
      if(event.keyCode == 27){
        methods.close();
      }
    });

    $(document).bind('touchstart click', function(event){
      if(!$(event.target).closest(settings['selector']).length){
        methods.close();
      }
    });

    return this.each(function(){
      $(settings['open'], this).bind('click', methods.open);
      $(settings['open'], this).parent().find(settings['close']).bind('click', function(event){
        methods.close();
      });
    });
  }

}).call(this);
