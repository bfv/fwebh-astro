
using core.data.DynamicQuery.

var DynamicQuery q.
var char content.

/*q = new DynamicQuery("constellation")*/
/*      :SetWhereClause("dec >= 0")    */
/*      :BuildQuery().                 */

q = new DynamicQuery("constellation", "dec >= 0")
      :BuildQuery().


do while not q:QueryHandle:query-off-end:
  //disp q:BufferHandle::abbreviation with 1 column.
  content += q:BufferHandle::name + ",".
  q:QueryHandle:get-next().  
end.

message trim(content, ",") view-as alert-box.

