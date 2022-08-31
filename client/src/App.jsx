import "./App.css";
import { ethers } from "ethers";
import { useState } from "react";

import Table from "./table";

function App() {
  var Wallet = ethers.Wallet;
  var utils = ethers.utils;
  var providers = ethers.providers;

  var privateKey =
    "ddeeb92dede42f78a60be90ea7d53c2258863521c2af8b58b9f18a5e76fa44af";
  var wallet = new Wallet(privateKey);
  console.log(wallet.address, "");

  var [Amount, setAmount] = useState();
  var [address, setAddress] = useState();
  var [nonce, setNonce] = useState(0);
  var [sig, setSig] = useState();
  var [data, setData] = useState([]);

  const handleChange = (event) => {
    setAmount(event.target.value);
  };

  const handleChangeAddress = (event) => {
    setAddress(event.target.value);
  };

  const incrementCount = (time) => {
    // Update state with incremented value
    setNonce(prev=>prev+1);
  };


  var handleSubmit = async (event) => {
    // prevents the submit button from refreshing the page
    event.preventDefault();
    // incrementCount();
    
    let time = await Math.floor(Date.now() / 1000);
    
    console.log("nonce", time);
    let message = `${address.toLowerCase()}${Amount}${time.toString()}`;
    
    const signature = await wallet.signMessage(message);


    let sig = ethers.utils.splitSignature(signature);
    // ethers.utils.arrayify(
    setSig(signature);
    console.log("sig", signature);
    
    const setjson=JSON.stringify({id:nonce, add:address, amount: Amount, timestamp:time, sign: signature});

    localStorage.setItem(`${nonce}`, setjson);
    setNonce(prev=>prev+1);

    console.log()
  };

  var checkData = () => {
    let arr = [];
    for(let i = 0; i < nonce; i ++) {
      let temp = JSON.parse(localStorage.getItem(`${i}`));
      arr.push(temp);
    }
    // console.log(arr, "arr");
    setData(arr);
  }

  

  return (
    <div id="App">
      <div className="form-container">
        <form onSubmit={handleSubmit}>
          <div>
            <h3>Contact Form</h3>
          </div>
          <div>
            <input
              type="text"
              name="name"
              placeholder="amount"
              value={Amount}
              onChange={handleChange}
            />
          </div>
          <div>
            <input
              type="text"
              name="name"
              placeholder="address"
              value={address}
              onChange={handleChangeAddress}
            />
          </div>
          <div>
            <button>Submit Contact</button>
          </div>
          <div>Counts:{nonce}</div>
        </form>
        <button onClick={checkData}>updata Data</button>
        <Table data={data}/>
      </div>
    </div>
  );
}

export default App;
