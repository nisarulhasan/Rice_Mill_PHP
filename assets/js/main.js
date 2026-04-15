
window.showToast = function(msg, type='success') {
  const c = document.getElementById('toast-container');
  if(!c) return;
  const div = document.createElement('div');
  div.className = `toast px-4 py-3 rounded-xl shadow-lg text-white ${type==='success'?'bg-gradient-to-r from-emerald-600 to-emerald-700':'bg-gradient-to-r from-rose-600 to-rose-700'}`;
  div.textContent = msg; c.appendChild(div); setTimeout(()=>div.remove(), 3500);
};

document.addEventListener('keydown', (e)=>{
  if(e.ctrlKey && e.key.toLowerCase()==='k'){e.preventDefault();document.getElementById('global-search')?.focus();}
  if(e.ctrlKey && e.key.toLowerCase()==='n'){e.preventDefault();showToast('Use New button to create records.');}
  if(e.ctrlKey && e.key.toLowerCase()==='s'){e.preventDefault();document.querySelector('form button[type=submit]')?.click();}
});

document.getElementById('dark-toggle')?.addEventListener('click', ()=>document.documentElement.classList.toggle('dark'));

$.ajaxSetup({
  headers: {'X-Requested-With':'XMLHttpRequest'}
});
