package nz.co.codec.flex.multicolumnform
{
    import flash.display.DisplayObject;

    import mx.containers.Form;
    import mx.core.EdgeMetrics;
    import mx.core.IInvalidating;
    import mx.core.IUIComponent;

    public class MultiColumnForm extends Form
    {
        public function MultiColumnForm()
        {
            super();
        }

        public var numColumns:int = 1;

        public var horizontalGap:Number = 0;

        private var columns:Array;

        private var cells:Array;

        private var numCells:int;

        private var measuredLabelWidths:Array = [];

        override protected function commitProperties():void
        {
            super.commitProperties();
            initColumns();
            cells = [];
            numCells = 0;
            var row:int = -1;
            var x:int = 0;
            var y:int = numChildren;
            for (var i:int = 0; i < y; i++)
            {
                var k:int = i % numColumns; // column #
                if (k == 0)
                {
                    cells[++row] = [];
                }
                var col:ColumnSpec = columns[k];
                if (cells[row].length == k)
                {
                    var child:IUIComponent = IUIComponent(getChildAt(x++));
                    if (child is MultiColumnFormItem)
                    {
                        MultiColumnFormItem(child).column = k;
                    }

                    if (!child.includeInLayout)
                    {
                        col.numChildrenWithOwnSpace += 1;
                        continue;
                    }

                    var cell:CellSpec = new CellSpec();
                    var colspan:int;
                    if (child is MultiColumnFormItem)
                    {
                        colspan = MultiColumnFormItem(child).colspan;
                    }
                    else
                    {
                        colspan = numColumns;
                    }
                    cell.colspan = colspan;
                    cells[row][k] = cell;
                    for (var j:int = 1; j < colspan; j++)
                    {
                        var cs:CellSpec = new CellSpec();
                        cs.colspan = 0;
                        cells[row][k + j] = cs;
                        y++;
                    }
                }
            }
            numCells = y;
        }

        /**
        * Initialise columns array
        */
        private function initColumns():void
        {
            columns = new Array(numColumns);
            for (var k:int = 0; k < numColumns; k++)
            {
                columns[k] = new ColumnSpec();
            }
        }

        override protected function measure():void
        {
            super.measure();

            var minWidth:Number = 0;
            var minHeight:Number = 0;

            var preferredWidth:Number = 0;
            var preferredHeight:Number = 0;

            var verticalGap:Number = getStyle("verticalGap");

            if (horizontalGap == 0)
            {
                horizontalGap = getStyle("horizontalGap");
            }

            initColumns();
            numCells = 0;

            var k:int = 0;      // column #
            var row:int = 0;
            var col:ColumnSpec;
            var cell:CellSpec;
            var x:int = 0;
            var y:int = numChildren;
            for (var i:int = 0; i < y; i++)
            {
                k = i % numColumns;
                col = columns[k];
                if (i > 0 && k == 0)
                {
                    // adjust height of cells to height of tallest cell in row
                    var rowHeight:Number = 0;
                    var c:int;
                    for (c = 0; c < numColumns; c++)
                    {
                        rowHeight = Math.max(rowHeight, cells[row][c].minHeight);
                    }
                    for (c = 0; c < numColumns; c++)
                    {
                        cells[row][c].minHeight = rowHeight;
                        cells[row][c].preferredHeight = rowHeight;
                    }
                    row++;
                }

                cell = cells[row][k];
                var colspan:int = cell.colspan;
                if (colspan > 0)
                {
                    var child:IUIComponent = IUIComponent(getChildAt(x++));

                    if (colspan == 1)
                    {
                        col.minWidth = Math.max(col.minWidth,
                            isNaN(child.percentWidth) ?
                            child.getExplicitOrMeasuredWidth() : child.minWidth);

                        col.preferredWidth = Math.max(col.preferredWidth,
                                                      child.getExplicitOrMeasuredWidth());
                    }
                    col.allowedWidth = Math.max(col.allowedWidth,
                                                child.getExplicitOrMeasuredWidth());

                    // Form.updateDisplayList currently always sets the child's height
                    // to be its measuredHeight, regardless of percentHeight
                    cell.minHeight = child.getExplicitOrMeasuredHeight();

                    cell.preferredHeight = child.getExplicitOrMeasuredHeight();

                    for (var j:int = 1; j < colspan; j++)
                    {
                        var cs:CellSpec = cells[row][k + j];
                        cs.minHeight = child.getExplicitOrMeasuredHeight();
                        cs.preferredHeight = child.getExplicitOrMeasuredHeight();
                        y++;
                    }
                }
                col.minHeight += cell.minHeight + verticalGap;
                col.preferredHeight += cell.preferredHeight + verticalGap;
            }
            numCells = y;

            for (k = 0; k < numColumns; k++)
            {
                col = columns[k];

//                minWidth += col.minWidth;
//                preferredWidth += col.preferredWidth;
                minWidth += col.allowedWidth;
                preferredWidth += col.allowedWidth;

                if (col.numChildrenWithOwnSpace > 1)
                {
                    var gap:Number = (col.numChildrenWithOwnSpace - 1) * getStyle("verticalGap");
                    col.minHeight += gap;
                    col.preferredHeight += gap;
                }

                minHeight = Math.max(minHeight, col.minHeight);
                preferredHeight = Math.max(preferredHeight, col.preferredHeight);

                // Always recalculate label width here.

                measuredLabelWidths[k] = NaN;
                measuredLabelWidths[k] = calculateLabelWidth(k);
            }

            // calc column width ratios
            for (k = 0; k < numColumns; k++)
            {
                col = columns[k];
                col.percentWidth = col.preferredWidth / preferredWidth;
            }

            minWidth += (numColumns - 1) * horizontalGap;
            preferredWidth += (numColumns - 1) * horizontalGap;

            // Add space for borders and margins.

            var vm:EdgeMetrics = viewMetricsAndPadding;

            var widthPadding:Number = vm.left + vm.right;
            var heightPadding:Number = vm.top + vm.bottom;

            minWidth += widthPadding;
            minHeight += heightPadding;

            preferredWidth += widthPadding;
            preferredHeight += heightPadding;

            measuredMinWidth = minWidth;
            measuredMinHeight = minHeight;

            measuredWidth = preferredWidth;
            measuredHeight = preferredHeight;
        }

        override protected function updateDisplayList(unscaledWidth:Number,
                                                      unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);

            var vm:EdgeMetrics = viewMetricsAndPadding;

            var left:Number = getStyle("paddingLeft");
            var top:Number = getStyle("paddingTop");

            var itemWidth:Number = unscaledWidth - vm.left - vm.right - ((numColumns - 1) * horizontalGap);

            var gap:Number = getStyle("verticalGap");

            var col:ColumnSpec;
            var cell:CellSpec;

            var k:int = 0;
            for (k = 0; k < numColumns; k++)
            {
                col = columns[k];
                col.itemWidth = col.percentWidth * itemWidth;
                col.top = top;
            }

            // Refuse to set itemWidth to be so small that a child
            // is forced to be less than its minWidth
            var child:IUIComponent;
            var row:int = 0;
            var i:int;
            var x:int = 0;
            for (i = 0; i < numCells; i++)
            {
                k = i % numColumns;
                if (i > 0 && k == 0)
                    row++;

                col = columns[k];
                cell = cells[row][k];

                if (cell.colspan > 0)
                {
                    child = IUIComponent(getChildAt(x++));
                    col.itemWidth = Math.max(col.itemWidth,
                        isNaN(child.percentWidth) ?
                        child.getExplicitOrMeasuredWidth() : child.minWidth);
                }
            }

            row = 0;
            x = 0;
            var offset:Number = left;
            for (i = 0; i < numCells; i++)
            {
                k = i % numColumns;
                if (i > 0 && k == 0)
                {
                    row++;
                    offset = left;
                }
                col = columns[k];
                cell = cells[row][k];
                if (cell.colspan > 0)
                {
                    child = IUIComponent(getChildAt(x++));
                    var newWidth:Number;
                    if (cell.colspan > 1)
                    {
                        var spanWidth:Number = 0;
                        var n:int = k + cell.colspan;
                        for (var j:int = k; j < n; j++)
                        {
                            spanWidth += columns[j].itemWidth;
                        }
                        spanWidth += (cell.colspan - 1) * horizontalGap;
                        if (isNaN(child.percentWidth))
                        {
                            newWidth = Math.min(spanWidth,
                                                child.getExplicitOrMeasuredWidth());
                        }
                        else
                        {
                            newWidth = Math.min(child.percentWidth, 100) * spanWidth / 100;
                        }
                    }
                    else
                    {
                        if (isNaN(child.percentWidth))
                        {
                            newWidth = Math.min(col.itemWidth,
                                                child.getExplicitOrMeasuredWidth());
                        }
                        else
                        {
                            newWidth = Math.min(child.percentWidth, 100) * (col.itemWidth / 100);
                        }
                    }
                    child.setActualSize(newWidth, child.getExplicitOrMeasuredHeight());
                    child.move(offset, col.top);
                }
                col.top += cell.preferredHeight;
                col.top += gap;
                offset += col.itemWidth + horizontalGap;
            }
        }

        internal function calculateLabelWidth(column:int):Number
        {
            // See if we've already calculated it.
            if (!isNaN(measuredLabelWidths[column]))
                return measuredLabelWidths[column];

            var labelWidth:Number = 0;

            // Determine best label width.
            var n:int = numChildren;
            for (var i:int = 0; i < n; i++)
            {
                var child:DisplayObject = getChildAt(i);
                if (child is MultiColumnFormItem)
                {
                    var item:MultiColumnFormItem = MultiColumnFormItem(child);
                    if (item.column == column)
                    {
                        labelWidth = Math.max(labelWidth,
                                              item.getPreferredLabelWidth());
                    }
                }
            }
            measuredLabelWidths[column] = labelWidth;

            return labelWidth;
        }

        internal function invalidateLabelWidth(column:int):void
        {
            // We only need to invalidate the label width
            // after we've been initialized.
            if (initialized)
            {
                measuredLabelWidths[column] = NaN;

                // Need to invalidate the size of all children
                // to make sure they respond to the label width change.
                var n:int = numChildren;
                for (var i:int = 0; i < n; i++)
                {
                    var child:IUIComponent = IUIComponent(getChildAt(i));
                    if (child is IInvalidating)
                    {
                        if (child is MultiColumnFormItem)
                        {
                            if (MultiColumnFormItem(child).column == column)
                                IInvalidating(child).invalidateSize();
                        }
                        else
                        {
                            IInvalidating(child).invalidateSize();
                        }
                    }
                }
            }
        }

    }
}