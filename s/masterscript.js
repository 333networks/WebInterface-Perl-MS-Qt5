//==============================================================================
// 333networks & subs
// Written by Darkelarious.
//
// This script belongs to 333networks. See
// 333networks.com for license and copyright.
//
//==============================================================================

// advanced search box
function toggleAdvanced ()
{
    var box = document.getElementById("advancedsearch");
    box.style.display = (box.style.display == "block" ? "none" : "block" );
}

// search box
{
    var qbox = document.getElementById('q');
    qbox.onclick = function ()
    {
        if ( this.value == 'search...' ) 
        {
            this.value = '';
            this.style.fontStyle = 'normal'
        }
    };
    
    qbox.onblur = function () 
    {
        if ( this.value.length < 1 ) 
        {
            this.value = 'search...';
            this.style.fontStyle = 'italic';
        }
    };
}
