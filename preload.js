const spawn = require("child_process").spawn;

window.addEventListener('DOMContentLoaded', () => {
  setOutput("Waiting for command");
  
  document.querySelector('#run-shell').addEventListener('click', (e) => {
    let params = []
    document.querySelectorAll('#param1, #param2, #param3').forEach(el => {
      if (el && el.value && el.value != "") {
        params.push(el.value);
      }
    });
    if (params.length != 3) {
      setOutput("Please Check Parameters and Retry");
      return;
    }else{
      document.querySelector('#param3').value = "";
    }
    toggleForm(false);
    setOutput("Proccess Started Please Wait");
    let bat = spawn(process.platform == 'win32' ? 'Powershell.exe' : "pwsh", [
      // "ls",
      // "pwsh",
      "-ExecutionPolicy",
      "remotesigned",
      "-File",
      __dirname+"/sources/ps1/command.ps1",
      ...params
    ]);
    bat.stdout.on("data", (data) => {
      newLineOutput(data.toString());
    });
    
    bat.stderr.on("data", (err) => {
      newLineOutput(err.toString());
      toggleForm(true);
    });
    
    bat.on("exit", (code) => {
      newLineOutput("exitted with code: "+code);
      toggleForm(true);
    });
  })
})

function setOutput(html){
  document.querySelector('#output').innerHTML = `${html}\n`;
}

function newLineOutput(html) {
  document.querySelector('#output').innerHTML = document.querySelector('#output').innerHTML+`${html}\n`;
}

function toggleForm(is) {
  if (is) {
    document.querySelector('#run-shell').innerHTML = "Run";
    document.querySelector('#param1').removeAttribute("disabled");
    document.querySelector('#param2').removeAttribute("disabled");
    document.querySelector('#param3').removeAttribute("disabled");
    document.querySelector('#run-shell').removeAttribute("disabled");
  }else{
    document.querySelector('#run-shell').innerHTML = "Running..";
    document.querySelector('#param1').setAttribute('disabled', !is);
    document.querySelector('#param2').setAttribute('disabled', !is);
    document.querySelector('#param3').setAttribute('disabled', !is);
    document.querySelector('#run-shell').setAttribute('disabled', !is);
  }
}