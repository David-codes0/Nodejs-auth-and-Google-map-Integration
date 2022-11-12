const mongoose = require('mongoose');


const  userSchema = mongoose.Schema({
    name: {
    required: true, // it must be there
    type: String, // the data type
    trim: true, // trim the user input in the server and can also be done in the client side
  },
  email: {
    required: true,
    type: String,
    trim: true,
    validate: {
      validator: (value) => {
        const re =
          /^(([^<>()[\]\.,;:\s@\"]+(\.[^<>()[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i; // Regex to check email input from user
        return value.match(re); // return  ture if it match with the regex
      },
      message: "Please enter a valid email address",
    },
  },
  password: {
    required: true,
    type: String, 
    // you can also add validator also
}
});


const User = mongoose.model("User", userSchema); // naming the  userSchema model as "User" 
module.exports = User; // exporting the user model