
const grad = (ctx, c1, c2) => { const g=ctx.createLinearGradient(0,0,0,200); g.addColorStop(0,c1); g.addColorStop(1,c2); return g; };
const line = document.getElementById('lineChart');
if(line){const c=line.getContext('2d'); new Chart(c,{type:'line',data:{labels:['Mon','Tue','Wed','Thu','Fri','Sat'],datasets:[{label:'Sales',data:[12,19,14,22,26,21],fill:true,backgroundColor:grad(c,'rgba(16,185,129,.35)','rgba(59,130,246,.05)'),borderColor:'#10b981',tension:.35}]},options:{responsive:true}})}
const bar = document.getElementById('barChart'); if(bar){new Chart(bar,{type:'bar',data:{labels:['A','B','C','D'],datasets:[{label:'Production',data:[8,6,9,7],backgroundColor:['#10b981','#3b82f6','#f59e0b','#6366f1']}]}})}
const dough = document.getElementById('doughnutChart'); if(dough){new Chart(dough,{type:'doughnut',data:{labels:['Raw','Finished','Byproduct'],datasets:[{data:[40,45,15],backgroundColor:['#10b981','#3b82f6','#f59e0b']}]}})}
const polar = document.getElementById('polarChart'); if(polar){new Chart(polar,{type:'polarArea',data:{labels:['North','South','East','West'],datasets:[{data:[11,16,9,14],backgroundColor:['#059669','#0284c7','#d97706','#7c3aed']}]}})}
