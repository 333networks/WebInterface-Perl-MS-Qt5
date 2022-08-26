//==============================================================================
// 333networks & subs
// Written by Darkelarious.
//
// This script belongs to 333networks. See
// 333networks.com for license and copyright.
//
//==============================================================================
// search box
{
    var qbox = document.getElementById('q');
    qbox.onclick = function ()
    {
        if ( this.value == 'filter...' ) 
        {
            this.value = '';
            this.style.fontStyle = 'normal'
        }
    };
    
    qbox.onblur = function () 
    {
        if ( this.value.length < 1 ) 
        {
            this.value = 'filter...';
            this.style.fontStyle = 'italic';
        }
    };
}
