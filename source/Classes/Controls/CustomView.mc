import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import Gfx;

module Views { module Controls
{
    class CustomView extends WatchUi.View
    {
        enum EScrollmode { SCROLL_SNAP, SCROLL_DRAG }

        var Items as Array<ViewItem> = new Array<ViewItem>[0];
        
        var ScrollMode = SCROLL_DRAG;
        var UI_dragThreshold = 40;
        
        var MainLayer;
        var ScrollbarLayer;
        static var ScrollbarSpace;

        private var _snapPosition = 0;
        private var _scrollOffset = 0;
        private var _paddingTop = null;
        private var _paddingBottom = null;

        protected var _margin = 0;
        protected var _verticalPadding = 0;
        protected var _BarWidthFactor = 0.05;
        protected var _fontoverride = null;

        protected var _scrollbar;
        protected var _hasTitle = false;
       
        function initialize()
        {
            View.initialize();
            self.Items = [];
        }

        function onLayout(dc as Dc)
        {
            View.onLayout(dc);

            self.UI_dragThreshold = (dc.getHeight() / 6).toNumber();
            self._verticalPadding = dc.getHeight() / 30;

            self._margin = 0;
            if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND)
            {
                var radius = dc.getWidth() / 2;
                self._margin = (radius - (radius * Math.sin(Math.toRadians(45)))).toNumber();
            }          

            self.ScrollbarSpace = ((dc.getWidth() - (2 * self._margin)) * self._BarWidthFactor).toNumber();

            var layerwidth = dc.getWidth() - (2 * self._margin);
            self.MainLayer = new WatchUi.Layer({:locX=>self._margin, :locY=>0, :width=>layerwidth, :height=>dc.getHeight()});
            self.addLayer(self.MainLayer);

            if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND)
            {
                self.ScrollbarLayer = new WatchUi.Layer({:locX =>dc.getWidth() / 2, :locY=>0, :width=>dc.getWidth() / 2, :height=>dc.getHeight()});
                self._scrollbar = new ScrollbarRound(self.ScrollbarSpace, 35);
                self.ScrollbarSpace = 0;
            }
            else
            {
                var barX = self.MainLayer.getX() + self.MainLayer.getDc().getWidth() - self.ScrollbarSpace;
                self.ScrollbarLayer = new WatchUi.Layer({:locX =>barX, :locY=>self.MainLayer.getY(), :width=>self.ScrollbarSpace, :height=>self.MainLayer.getDc().getHeight()});
                self._scrollbar = new ScrollbarRectangle();    
            }

            self.addLayer(self.ScrollbarLayer);
        }

        function drawList() as Void 
        {
            if (self.MainLayer == null)
            {
                return false;
            }

            var dc = self.MainLayer.getDc();
            dc.setColor(getTheme().ListBackground, getTheme().ListBackground);
            dc.clear();
            dc.setAntiAlias(true);

            if (self.Items.size() > 0)
            {
                var y;
                if (self.ScrollMode == SCROLL_SNAP)
                {
                    y = self.getCenterItem(dc, self._snapPosition);
                    if (self._snapPosition == 0 && y < self._margin)
                    {
                        y = self._margin;
                    }
                }
                else
                {
                    y = self._scrollOffset + self._margin;
                }
            
                var scrollY = y - self.getPaddingTop(dc) - self._margin;
                scrollY *= -1;

                for (var i = 0; i < self.Items.size(); i++)
                {
                    var item = self.Items[i];
                    if (y > dc.getHeight())
                    {
                        //outside lower screenborder
                        item.setBoundaries(-1,-1);
                    }
                    else if (y < (item.getHeight() * -1))
                    {
                        //outside upper screenborder
                        item.setBoundaries(-1,-1);
                        y += item.getHeight();
                    }
                    else
                    {   
                        y = item.draw(dc, y, i != self.Items.size() - 1);
                    }
                }

                if (self._scrollbar != null && self.ScrollbarLayer != null)
                {
                    var totalheight = self.getTotalHeight(dc);                    
                    var viewport = dc.getHeight() - (self._margin * 2);
                    var maxscroll = totalheight - viewport;
                    self._scrollbar.draw(self.ScrollbarLayer.getDc(), scrollY.toFloat(), maxscroll.toFloat(), totalheight.toFloat(), viewport);
                }                
            }
        }

        function addItem(title as String, substring as String?, identifier as Object?, icon as Number or BitmapResource or Null, position as Number) as Void
        {
            self.Items.add(new ViewItem(self.MainLayer.getDc(), title, substring, identifier, icon, self._verticalPadding, position, self._fontoverride));
        }

        function setTitle(title as String) as Void
        {
            if (title != null && title.length() > 0)
            {
                var items = [];
                if (self.Items.size() > 0)
                {
                    items = [ self.Items ];
                    if (self._hasTitle == true)
                    {
                        items = items.slice(1, null);
                    }
                }
                self._hasTitle = true;
                self.Items = [];
                self.Items.add(new TitleViewItem(self.MainLayer.getDc(), title));
                if (items.size() > 0)
                {
                    self.Items.addAll(items);
                }
            }
        }

        function needScrollbar() as Boolean
        {
            return self.MainLayer.getDc().getHeight() - (self._margin * 2) < self.getTotalHeight(self.MainLayer.getDc());
        }

        function onScroll(delta as Number) as Void
        {
            if (delta == 0 || self.MainLayer == null)
            {
                return;
            }            

            if (self.ScrollMode == SCROLL_SNAP)
            {
                self.moveIterator(delta > 0 ? 1 : -1);
            }
            else if (self.needScrollbar())
            {
                var startoffset = self._scrollOffset;
                self._scrollOffset -= delta;

                var viewport = self.MainLayer.getDc().getHeight() - (self._margin * 2);
                var maxscroll = self.getTotalHeight(self.MainLayer.getDc()) - viewport;
                var minY = -maxscroll;

                if (self._scrollOffset < minY)
                {
                    self._scrollOffset = minY;
                }
                else if (self._scrollOffset > 0)
                {
                    self._scrollOffset = 0;
                }

                if (startoffset != self._scrollOffset)
                {
                    WatchUi.requestUpdate();
                }
            }
        }

        function onListTap(position as Number, item as ViewItem) as Void;
        function onDoubleTap(x as Number, y as Number) as Void;
        function onTap(x as Number, y as Number) as Boolean
        {
            if (self.MainLayer == null)
            {
                return false;
            }
            
            if (x < self.MainLayer.getX() || x > self.MainLayer.getX() + self.MainLayer.getDc().getWidth() || y < self.MainLayer.getY() || y > self.MainLayer.getY() + self.MainLayer.getDc().getHeight())
            {
                return false;
            }

            for (var i = 0; i < self.Items.size(); i++)
            {
                var item = self.Items[i];
                if (item.Clicked(y))
                {
                    self.onListTap(i, item);
                    return true;
                }
            }

            return false;
        }

        protected function moveIterator(delta as Number?) as Void 
        {
            if (delta == null)
            {
                self._snapPosition = 0;
                return;
            }
            var pos = self._snapPosition;
            self._snapPosition += delta;
            if (self._snapPosition < 0)
            {
                self._snapPosition = 0;
            }

            if (self._snapPosition > self.Items.size() - 1)
            {
                self._snapPosition = self.Items.size() - 1;
            }

            if (pos != self._snapPosition)
            {
                WatchUi.requestUpdate();
            }
        }

        private function getCenterItem(dc as Dc, index as Number) as Number
        {
            var y = 0;
            for (var i = 0; i < index; i++)
            {
                y -= self.Items[i].getHeight();
            }

            y += (self.MainLayer.getDc().getHeight() - self.Items[index].getHeight()) / 2;
            return y;
        }

        private function getTotalHeight(dc as Dc) as Number
        {
            var height = 0;
            for (var i = 0; i < self.Items.size(); i++)
            {
                height += self.Items[i].getHeight();
            }

            height += self.getPaddingTop(dc) + self.getPaddingBottom(dc);
            return height;
        }

        private function getPaddingTop(dc as Dc) as Number
        {
            if (self._paddingTop == null)
            {
                if (self.ScrollMode == SCROLL_SNAP)
                {
                    self._paddingTop = (self.MainLayer.getDc().getHeight() / 2) - self._margin - (self.Items[0].getHeight() / 2).toNumber();
                }
                else
                {
                    self._paddingTop = 0;
                }
            }

            return self._paddingTop;
        }

        private function getPaddingBottom(dc as Dc) as Number
        {
            if (self._paddingBottom == null)
            {
                if (self.ScrollMode == SCROLL_SNAP)
                {
                    self._paddingBottom = (self.MainLayer.getDc().getHeight() / 2) - self._margin - (self.Items[self.Items.size() - 1].getHeight() / 2).toNumber();
                }
                else
                {
                    self._paddingBottom = 0;
                }
            }
            return self._paddingBottom;
        }
    }
}}