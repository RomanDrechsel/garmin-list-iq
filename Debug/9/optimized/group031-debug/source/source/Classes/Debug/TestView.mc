import Controls.Listitems;
import Views;
import Helper;
import Toybox.Graphics;
import Toybox.Lang;

(:debug)
module Debug {
    class TestView extends Views.ItemView {
        function initialize() {
            ItemView.initialize();
        }

        function onLayout(dc as Dc) as Void {
            ItemView.onLayout(dc);
            self.loadVisuals(dc);
        }

        private function loadVisuals(dc as Dc) as Void {
            //var text = "Hallo WELT, Ich bin ein   Sehr Langer Text\nUnd habe einen Festen\n\nZeilenumbruch\n\n";
            //var text = "Ab Ab Ab Ab A A A bAb bA bA Ab bA A Ab A A A A A A A A A A A A A \nA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A ";
            dc /*>text<*/ = Graphics.fitTextToArea(
                "大家好，我有一篇翻译成中文的很长的文章。大家好，我有一篇翻译成中文的很长的文章。大家好，我有一篇翻译成中文的很长的文章。大家好，我有一篇翻译成中文的很长的文章。",
                Helper.Fonts.Normal(),
                dc.getWidth(),
                9999999,
                true
            );
            self.Items = [];
            self.addItem(dc /*>text<*/, null, null, null, 0);
        }
    }
}
