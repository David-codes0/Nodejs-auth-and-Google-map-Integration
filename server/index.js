const express  = require("express");
const mongoose = require("mongoose");
const authRouter = require("./routes/auth");

const PORT = 3000;
const app = express();


app.use(express.json());

app.use(authRouter);

const DB = 'mongodb+srv://adebayo17108:adebayo17108@cluster0.vo4i8e3.mongodb.net/test';

mongoose.connect(DB).then(()=> {
    console.log('connection sucessful');
}).catch((e)=> {
console.log(e);
});
app.listen(PORT, "0.0.0.0", ()=> {
    console.log('It is now connected to ${PORT}');
}); // .listen(the port, the ip address which is from any where, call back)

