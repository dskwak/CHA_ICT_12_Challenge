$.ready(function(){
    id_value = document.getElementById('id_wrap').children[1].value;
    pw_value = document.getElementById('pw_wrap').children[1].value;
    console.log(id_value, pw_value)
    $('button').click(function(){
        console.log(id_value, pw_value)
    })
})