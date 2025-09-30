async function s(e){return new Promise(o=>{chrome.storage.local.get(e,r=>{o(r)})})}async function t(e){return new Promise(o=>{chrome.storage.local.set(e,()=>{o()})})}export{s as g,t as s};
