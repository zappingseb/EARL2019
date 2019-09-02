Array.prototype.remove = function() {
    var what, a = arguments, L = a.length, ax;
    while (L && this.length) {
        what = a[--L];
        while ((ax = this.indexOf(what)) !== -1) {
            this.splice(ax, 1);
        }
    }
    return this;
};

function ziehen(ev) {
  ev.dataTransfer.setData('text', ev.target.id);
}
    
function ablegenErlauben(ev) {
  ev.preventDefault();
}
function removeAllOthers(col_field, value_of_elem) {
  all_columns = ['x_columns_value', 'y_columns_value', 'facet_columns_value']
  all_columns.remove(col_field)
  var i;
  var to = all_columns.length;
  for (i=0; i < to; i++) { 
    value_to_set = all_columns[i]
    document.getElementsByName(value_to_set)[0].value = document.getElementsByName(value_to_set)[0].value.replace(value_of_elem, '')
  }
}    

function ablegen(ev) {
  ev.preventDefault();
  var data = ev.dataTransfer.getData('text');
  ev.target.appendChild(document.getElementById(data));
  if (ev.target.id == 'x_columns') {
    document.getElementsByName('x_columns_value')[0].value += ',' + ev.dataTransfer.getData('text');
    removeAllOthers('x_columns_value', ev.dataTransfer.getData('text'));
  } else if (ev.target.id == 'y_columns') {
    document.getElementsByName('y_columns_value')[0].value += ',' + ev.dataTransfer.getData('text');
    removeAllOthers('y_columns_value', ev.dataTransfer.getData('text'));
  } else if (ev.target.id == 'facet_columns') {
    document.getElementsByName('facet_columns_value')[0].value += ',' + ev.dataTransfer.getData('text');
    removeAllOthers('facet_columns_value', ev.dataTransfer.getData('text'));
  } else{
    removeAllOthers('', ev.dataTransfer.getData('text'));
  }
  Shiny.onInputChange('x_columns', document.getElementsByName('x_columns_value')[0].value);
  Shiny.onInputChange('y_columns', document.getElementsByName('y_columns_value')[0].value);
  Shiny.onInputChange('facet_columns', document.getElementsByName('facet_columns_value')[0].value);
}