
function calculateQuality(formId){
  const f=document.getElementById(formId); if(!f) return;
  const fd=new FormData(f);
  fetch('/api/calculate_quality_deduction.php',{method:'POST',body:fd})
    .then(r=>r.json())
    .then(d=>{
      if(!d.success) return;
      document.getElementById('total_deduction').textContent = d.total_deduction_pct.toFixed(2)+'%';
      document.getElementById('final_rate').textContent = d.final_rate.toFixed(2);
    });
}
