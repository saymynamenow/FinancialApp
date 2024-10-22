import jwt from 'jsonwebtoken';

function authentification(req,res, next){
    const authHeader = req.headers['authorization'];
    const token = authHeader.split(' ')[1]; 
    // console.log(token);

    if(!token){
        res.status(401).json({message: 'No token provided'});
    }else{
        jwt.verify(token, 'fiqriGanteng' , (err, decoded) =>{
            if(err){
                res.status(401).json({message: 'Unauthorized', error: err});
            }else{
                req.user = decoded.data,
                next()
            }
        })
    }
}

export default authentification;