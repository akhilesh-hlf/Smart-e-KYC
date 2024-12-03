const { create } = require("ipfs-http-client");
// import { create } from 'ipfs-http-client'

async function ipfsClient(){
   const ipfs= await create(
       {
           host:"localhost",
           port:5001,
           protocol:"http"
       }
   );
return ipfs
}


async function saveText(){


let ipfs=await ipfsClient();


let result=await ipfs.add("pragyan");
console.log(result);


}
saveText();
// import { create } from 'ipfs-http-client'
// //const client = create()
// const client = create(new URL('http://127.0.0.1:5001'))
// const { cid } = client.add('Hello world!')