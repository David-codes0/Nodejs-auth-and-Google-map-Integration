const express  = require("express"); // majorly for routing
const authRouter = express.Router(); // for authRouter.get instead of app.get or app.post.
const bcryptjs =require("bcryptjs");
const User = require("../models/user");
const jwt = require("jsonwebtoken");
const auth = require("../middleware/auth");

//Sign up

authRouter.post("/api/signup",async (req,res) => {
    try{
          const {name, email, password} = req.body; // create a constructor

    const existingUSer = await User.findOne({email});

    if(existingUSer){
        return res.status(400)// bad request
        .json({msg: 'User with same email already exists'});
    }

    const hashedPassword = await bcryptjs.hash(password, 8);

    let user = new User({
        email,password: hashedPassword,name,
    });

   user = await user.save();  // to save to mongo DB
    res.json(user);

    }catch(e){
        res.status(500).json({
            error: e.message
        });
    }
  
})


// Sign in
authRouter.post("/api/signin",async (req,res) => {
   try {
    const { email, password } = req.body;

    const user = await User.findOne({ email }); // It is use to check whether the email is registered in the DB
    if (!user) {
      return res
        .status(400)
        .json({ msg: "User with this email does not exist!" }); // 
    }

    const isMatch = await bcryptjs.compare(password, user.password);// compare user input password with the bcrypt password
    if (!isMatch) {
      return res.status(400).json({ msg: "Incorrect password." });
    }

    const token = jwt.sign({ id: user._id }, "passwordKey");   // using the user id as the token for user to access every attribute of the app 
    res.json({ token, ...user._doc }); // user._doc is use to just show only the necessary info abut the user
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
  
});

authRouter.post("/tokenIsValid", async (req, res) => {
  try {
    const token = req.header("x-auth-token");
    if (!token) return res.json(false);
    const verified = jwt.verify(token, "passwordKey");
    if (!verified) return res.json(false);

    const user = await User.findById(verified.id);
    if (!user) return res.json(false);
    res.json(true);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// get user data
authRouter.get("/", auth, async (req, res) => {
  const user = await User.findById(req.user);
  res.json({ ...user._doc, token: req.token });
});


module.exports = authRouter;