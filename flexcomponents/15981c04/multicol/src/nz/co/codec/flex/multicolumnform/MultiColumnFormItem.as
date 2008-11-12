package nz.co.codec.flex.multicolumnform
{
    import flash.display.DisplayObject;
    import flash.events.Event;

    import mx.containers.FormItemDirection;
    import mx.containers.utilityClasses.Flex;
    import mx.controls.FormItemLabel;
    import mx.core.Container;
    import mx.core.EdgeMetrics;
    import mx.core.IFlexDisplayObject;
    import mx.core.IUIComponent;
    import mx.core.ScrollPolicy;
    import mx.core.mx_internal;
    import mx.events.FlexEvent;

    use namespace mx_internal;

    //--------------------------------------
    //  Styles
    //--------------------------------------

    /**
     *  Number of pixels between children in the horizontal direction.
     *  The default value depends on the component class;
     *  if not overriden for the class, the default value is 8.
     */
    [Style(name="horizontalGap", type="Number", format="Length", inherit="no")]

    /**
     *  Number of pixels between children in the vertical direction.
     *  The default value depends on the component class;
     *  if not overriden for the class, the default value is 6.
     */
    [Style(name="verticalGap", type="Number", format="Length", inherit="no")]

    /**
     *  Horizontal alignment of children in the container.
     *  Possible values are <code>"left"</code>, <code>"center"</code>,
     *  and <code>"right"</code>.
     *
     *  @default "left"
     */
    [Style(name="horizontalAlign", type="String", enumeration="left,center,right", inherit="no")]

    /**
     *  Number of pixels between the label and child components of the form item.
     *
     *  @default 14
     */
    [Style(name="indicatorGap", type="Number", format="Length", inherit="yes")]

    /**
     *  Specifies the skin to use for the required field indicator.
     *
     *  @default mx.containers.FormItem.Required
     */
    [Style(name="indicatorSkin", type="Class", inherit="no")]

    /**
     *  Width of the form labels.
     *  The default is the length of the longest label in the form.
     */
    [Style(name="labelWidth", type="Number", format="Length", inherit="yes")]

    /**
     *  Number of pixels between the container's bottom border
     *  and the bottom edge of its content area.
     *
     *  @default 0
     */
    [Style(name="paddingBottom", type="Number", format="Length", inherit="no")]

    /**
     *  Number of pixels between the container's right border
     *  and the right edge of its content area.
     *
     *  @default 0
     */
    [Style(name="paddingRight", type="Number", format="Length", inherit="no")]

    /**
     *  Number of pixels between the container's top border
     *  and the top edge of its content area.
     *
     *  @default 0
     */
    [Style(name="paddingTop", type="Number", format="Length", inherit="no")]

    //--------------------------------------
    //  Excluded APIs
    //--------------------------------------

    [Exclude(name="focusIn", kind="event")]
    [Exclude(name="focusOut", kind="event")]

    [Exclude(name="focusBlendMode", kind="style")]
    [Exclude(name="focusSkin", kind="style")]
    [Exclude(name="focusThickness", kind="style")]

    [Exclude(name="focusInEffect", kind="effect")]
    [Exclude(name="focusOutEffect", kind="effect")]

    //--------------------------------------
    //  Other metadata
    //--------------------------------------

    [IconFile("FormItem.png")]

    public class MultiColumnFormItem extends Container
    {
        public function MultiColumnFormItem()
        {
            super();
            _horizontalScrollPolicy = ScrollPolicy.OFF;
            _verticalScrollPolicy = ScrollPolicy.OFF;
        }

        [Embed(source="Assets.swf",symbol="mx.containers.FormItem.Required")]
        private var indicatorImage:Class;

        public var colspan:int = 1;

        public var column:int = 0;

        private var labelObj:FormItemLabel;

        private var guessedRowWidth:Number;

        private var guessedNumColumns:int;

        /**
         *  @private
         *  Storage for the label property.
         */
        private var _label:String = "";

        [Bindable("labelChanged")]
        [Inspectable(category="General", defaultValue="")]

        /**
         *  Text label for the FormItem. This label appears to the left of the
         *  child components of the form item.
         *  The default value is the empty String ("").
         */
        override public function get label():String
        {
            return _label;
        }

        /**
         *  @private
         */
        override public function set label(value:String):void
        {
            _label = value;

            invalidateProperties();

            dispatchEvent(new Event("labelChanged"));
        }

        /**
         *  @private
         *  Storage for the direction property.
         */
        private var _direction:String = FormItemDirection.VERTICAL;

        [Bindable("directionChanged")]
        [Inspectable(category="General", enumeration="vertical,horizontal", defaultValue="vertical")]

        public function get direction():String
        {
            return _direction;
        }

        /**
         *  @private
         */
        public function set direction(value:String):void
        {
            _direction = value;

            invalidateSize();
            invalidateDisplayList();

            dispatchEvent(new Event("directionChanged"));
        }

        internal function get labelObject():Object
        {
            return labelObj;
        }

        /**
         *  @private
         *  Storage for the required property.
         */
        private var _required:Boolean = false;

        [Bindable("requiredChanged")]
        [Inspectable(category="General", defaultValue="false")]

        public function get required():Boolean
        {
            return _required;
        }

        /**
         *  @private
         */
        public function set required(value:Boolean):void
        {
            if (value != _required)
            {
                _required = value;

                invalidateDisplayList();

                dispatchEvent(new Event("requiredChanged"));
            }
        }

        /**
         *  @private
         */
        override protected function commitProperties():void
        {
            super.commitProperties();

            createItemLabel();
        }

        internal function getPreferredLabelWidth():Number
        {
            createItemLabel();

            if (labelObj == null)
                return 0;

            if (isNaN(labelObj.measuredWidth))
                labelObj.validateSize();
            var labelWidth:Number = labelObj.measuredWidth;

            if (isNaN(labelWidth))
                return 0;

            return labelWidth;
        }

        private function createItemLabel():void
        {
            // See if we need to create our label mc
            if (label.length > 0)
            {
                if (!labelObj)
                {
                    labelObj = new FormItemLabel();
                    labelObj.styleName = this;
                    rawChildren.addChild(labelObj);
                }

                if (labelObj.text != label)
                {
                    labelObj.text = label;

                    labelObj.validateSize();

                    invalidateSize();
                    invalidateDisplayList();

                    // Changing the label could affect the overall form label width
                    // so we need to invalidate our parent's size here too
                    if (parent is MultiColumnForm)
                        MultiColumnForm(parent).invalidateLabelWidth(column);
                }
            }

            // See if we need to destroy our label mc
            if (label.length == 0 && labelObj)
            {
                rawChildren.removeChild(labelObj);
                labelObj = null;

                invalidateSize();
                invalidateDisplayList();
            }
        }

        override protected function measure():void
        {
            super.measure();

            var numColumns:int = guessedNumColumns =
                calcNumColumns(guessedRowWidth);

            var horizontalGap:Number = getStyle("horizontalGap");
            var verticalGap:Number = getStyle("verticalGap");
            var indicatorGap:Number = getStyle("indicatorGap");

            var col:int = 0;

            var tempMinWidth:Number = 0;
            var tempWidth:Number = 0;
            var tempMinHeight:Number = 0;
            var tempHeight:Number = 0;

            var minWidth:Number = 0;
            var minHeight:Number = 0;
            var preferredWidth:Number = 0;
            var preferredHeight:Number = 0;
            var maxPreferredWidth:Number = 0;

            var n:int = numChildren;
            var i:int;
            var child:IUIComponent;

            // If direction == FormItemDirection.HORIZONTAL
            // and the children span multiple rows,
            // then updateDisplayList() (below) sets each child's width to the
            // preferredWidth of the largest child.
            if (direction == FormItemDirection.HORIZONTAL && numColumns < n)
            {
                for (i = 0; i < n; i++)
                {
                    child = IUIComponent(getChildAt(i));
                    maxPreferredWidth = Math.max(
                        maxPreferredWidth, child.getExplicitOrMeasuredWidth());
                }
            }

            for (i = 0; i < n; i++)
            {
                child = IUIComponent(getChildAt(i));

                if (col < numColumns)
                {
                    tempMinWidth += !isNaN(child.percentWidth) ?
                                    child.minWidth :
                                    child.getExplicitOrMeasuredWidth();

                    tempWidth += (maxPreferredWidth > 0) ?
                                 maxPreferredWidth :
                                 child.getExplicitOrMeasuredWidth();

                    if (col > 0)
                    {
                        tempMinWidth += horizontalGap;
                        tempWidth += horizontalGap;
                    }

                    tempMinHeight = Math.max(tempMinHeight,
                                             !isNaN(child.percentWidth) ?
                                             child.minHeight :
                                             child.getExplicitOrMeasuredHeight());

                    tempHeight = Math.max(tempHeight,
                                          child.getExplicitOrMeasuredHeight());
                }

                col++;

                if (col >= numColumns || i == n - 1)
                {
                    minWidth = Math.max(minWidth, tempMinWidth);
                    preferredWidth = Math.max(preferredWidth, tempWidth);

                    minHeight += tempMinHeight;
                    preferredHeight += tempHeight;

                    if (i > 0)
                    {
                        minHeight += verticalGap;
                        preferredHeight += verticalGap;
                    }

                    col = 0;

                    tempMinWidth = 0;
                    tempWidth = 0;

                    tempMinHeight = 0;
                    tempHeight = 0;
                }
            }

            var labelWidth:Number = getLabelWidth() + indicatorGap;
            minWidth += labelWidth;
            preferredWidth += labelWidth;

            if (labelObj)
            {
                minHeight = Math.max(minHeight,
                                     labelObj.getExplicitOrMeasuredHeight());

                preferredHeight = Math.max(preferredHeight,
                                           labelObj.getExplicitOrMeasuredHeight());
            }

            var vm:EdgeMetrics = viewMetricsAndPadding;

            minHeight += vm.top + vm.bottom;
            minWidth += vm.left + vm.right;

            preferredHeight += vm.top + vm.bottom;
            preferredWidth += vm.left + vm.right;

            measuredMinWidth = minWidth;
            measuredMinHeight = minHeight;

            measuredWidth = preferredWidth;
            measuredHeight = preferredHeight;

        }

        private function getLabelWidth():Number
        {
            var labelWidth:Number = getStyle("labelWidth");

            // labelWidth of 0 is the same as NaN
            if (labelWidth == 0)
                labelWidth = NaN;

            if (isNaN(labelWidth) && parent is MultiColumnForm)
                labelWidth = MultiColumnForm(parent).calculateLabelWidth(column);

            if (isNaN(labelWidth))
                labelWidth = getPreferredLabelWidth();

            return labelWidth;
        }

        private function calcNumColumns(w:Number):int
        {
            var totalWidth:Number = 0;
            var maxChildWidth:Number = 0;
            var horizontalGap:Number = getStyle("horizontalGap");

            if (direction != FormItemDirection.HORIZONTAL)
                return 1;

            var n:int = numChildren;
            for (var i:int = 0; i < n; i++)
            {
                var child:IUIComponent = IUIComponent(getChildAt(i));
                var childWidth:Number = child.getExplicitOrMeasuredWidth();

                maxChildWidth = Math.max(maxChildWidth, childWidth);
                totalWidth += childWidth;
                if (i > 0)
                    totalWidth += horizontalGap;
            }

            // See if everything can fit in a single row
            if (isNaN(w) || totalWidth <= w)
                return n;

            // if the width is enough to contain two children use two columns
            if (maxChildWidth*2 <= w)
                return 2;

            // Default is single column
            return 1;
        }

        private var indicatorObj:IFlexDisplayObject;

        private var alreadyGuessedAgain:Boolean = false;

        override protected function updateDisplayList(unscaledWidth:Number,
                                                      unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            var vm:EdgeMetrics = viewMetricsAndPadding;
            var left:Number = vm.left;
            var top:Number = vm.top;

            var y:Number = top;
            var labelWidth:Number = getLabelWidth();
            var indicatorGap:Number = getStyle("indicatorGap");
            var horizontalAlign:String = getStyle("horizontalAlign");
            var i:int;
            var child:IUIComponent;
            var childBaseline:Number;
            var childWidth:Number;
            var horizontalGap:Number;
            var verticalGap:Number;

            var horizontalAlignValue:Number;
            if (horizontalAlign == "right")
                horizontalAlignValue = 1;
            else if (horizontalAlign == "center")
                horizontalAlignValue = 0.5;
            else
                horizontalAlignValue = 0;

            var n:int = numChildren;

            // Position our label.
            if (labelObj)
            {
                if (n > 0)
                {
                    // Center label with first child
                    child = IUIComponent(getChildAt(0));
                    childBaseline = child.baselinePosition;
                    if (!isNaN(childBaseline))
                        y += childBaseline - labelObj.baselinePosition;
                }

                // Set label size.
                childWidth = Math.min(labelObj.getExplicitOrMeasuredWidth(),
                                      labelWidth);
                labelObj.setActualSize(childWidth,
                                       labelObj.getExplicitOrMeasuredHeight());
                labelObj.move(left + labelWidth - childWidth, y);
            }
            left += labelWidth;

            // Position the "required" indicator.
            displayIndicator(left, y);
            left += indicatorGap;

            var controlWidth:Number = unscaledWidth - vm.right - left;
            if (controlWidth < 0)
                controlWidth = 0;

            // Position our children.
            if (direction == FormItemDirection.HORIZONTAL)
            {
                var maxWidth:Number = 0;
                var numColumns:int = calcNumColumns(controlWidth);
                var x:Number;
                var col:int = 0;

                horizontalGap = getStyle("horizontalGap");
                verticalGap = getStyle("verticalGap");

                // Earlier, the measure function took a guess at the number
                // of columns, but that function didn't know the width of this
                // FormItem.  Now that we know the width, we may discover that the
                // guess was wrong.  In that case, call invalidateSize(), so that
                // we loop back and repeat the measurement phase again.
                //
                // It's possible that we might introduce an infinite loop - the
                // new guess might change the layout, so that the guess once again
                // is found to be wrong.  If we get back here a second time and
                // discover that the guess is still wrong, we'll just live with it.
                if (numColumns != guessedNumColumns && !alreadyGuessedAgain)
                {
                    guessedRowWidth = controlWidth;
                    alreadyGuessedAgain = true;
                    invalidateSize();
                }
                else
                {
                    alreadyGuessedAgain = false;
                }

                // Special case for single row - use the HBox layout algorithm.
                if (numColumns == n)
                {
                    var h:Number = height - (top + vm.bottom);
                    var excessSpace:Number = Flex.flexChildWidthsProportionally(
                        this, controlWidth - (n - 1) * horizontalGap, h);

                    left += (excessSpace * horizontalAlignValue);

                    for (i = 0; i < n; i++)
                    {
                        child = IUIComponent(getChildAt(i));
                        child.move(Math.floor(left), top);
                        left += child.width + horizontalGap;
                    }
                }
                else
                {
                    // Determine the widest child.
                    for (i = 0; i < n; i++)
                    {
                        child = IUIComponent(getChildAt(i));
                        maxWidth = Math.max(maxWidth,
                                            child.getExplicitOrMeasuredWidth());
                    }

                    // Determine the left side for the columns.
                    var widthSlop:Number = controlWidth -
                        (numColumns * maxWidth + (numColumns - 1) * horizontalGap);
                    if (widthSlop < 0)
                        widthSlop = 0;

                    left += (widthSlop * horizontalAlignValue);
                    x = left;

                    // Place the children in columns
                    for (i = 0; i < n; i++)
                    {
                        child = IUIComponent(getChildAt(i));

                        childWidth = Math.min(maxWidth,
                                              child.getExplicitOrMeasuredWidth());

                        child.setActualSize(childWidth,
                                            child.getExplicitOrMeasuredHeight());
                        child.move(x, top);

                        if (++col >= numColumns)
                        {
                            x = left;
                            col = 0;
                            top += child.height + verticalGap;
                        }
                        else
                        {
                            x += maxWidth + horizontalGap;
                        }
                    }
                }
            }
            else
            {
                verticalGap = getStyle("verticalGap");

                for (i = 0; i < n; i++)
                {
                    child = IUIComponent(getChildAt(i));

                    // Round up to nearest 1/4 of controlWidth
                    if (!isNaN(child.percentWidth))
                    {
                        childWidth = Math.floor(controlWidth *
                            Math.min(child.percentWidth, 100) / 100);
                    }
                    else
                    {
                        childWidth = child.getExplicitOrMeasuredWidth();

                        // Only do modular sizing if an explicit width isn't set.
                        if (isNaN(child.explicitWidth))
                        {
                            if (childWidth < Math.floor(controlWidth * 0.25))
                                childWidth = Math.floor(controlWidth * 0.25);
                            else if (childWidth < Math.floor(controlWidth * 0.5))
                                childWidth = Math.floor(controlWidth * 0.5);
                            else if (childWidth < Math.floor(controlWidth * 0.75))
                                childWidth = Math.floor(controlWidth * 0.75);
                            else if (childWidth < Math.floor(controlWidth))
                                childWidth = Math.floor(controlWidth);
                        }
                    }

                    child.setActualSize(childWidth,
                                        child.getExplicitOrMeasuredHeight());

                    var xOffset:Number = (controlWidth - childWidth) * horizontalAlignValue;
                    child.move(left + xOffset, top);

                    top += child.height;
                    top += verticalGap;
                }
            }

            // Position our label again, now that our children have been positioned.
            // Moving our children can affect the baselinePosition. (Bug 86725)
            if (labelObj)
            {
                y = vm.top;
                if (n > 0)
                {
                    // Center label with first child
                    child = IUIComponent(getChildAt(0));
                    childBaseline = child.baselinePosition;
                    if (!isNaN(childBaseline))
                        y += childBaseline - labelObj.baselinePosition;
                }
                labelObj.move(labelObj.x, y);
            }
        }

        private function displayIndicator(xPos:Number, yPos:Number):void
        {
            if (required)
            {
                if (!indicatorObj)
                {
                    var indicatorClass:Class = getStyle("indicatorSkin") as Class;
                    if (indicatorClass)
                    {
                        indicatorObj = IFlexDisplayObject(new indicatorClass());
                    }
                    else
                    {
                        indicatorObj = IFlexDisplayObject(new indicatorImage());
                    }
                    rawChildren.addChild(DisplayObject(indicatorObj));
                }

                indicatorObj.x =
                    xPos + ((getStyle("indicatorGap") - indicatorObj.width) / 2);

                if (labelObj)
                {
                    indicatorObj.y = yPos +
                        (labelObj.getExplicitOrMeasuredHeight() -
                         indicatorObj.measuredHeight) / 2;
                }
            }
            else
            {
                if (indicatorObj)
                {
                    rawChildren.removeChild(DisplayObject(indicatorObj));
                    indicatorObj = null;
                }
            }
        }

        /**
         *  @private
         */
        mx_internal function get itemLabel():FormItemLabel
        {
            return labelObj;
        }

    }
}