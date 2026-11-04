from fastapi import HTTPException, status

UnauthorizedException = HTTPException(
    status_code=status.HTTP_401_UNAUTHORIZED, 
    detail="Not authorized",
    headers={"WWW-Authenticate": "Bearer"},
)

InvalidCredentials = HTTPException(
    status_code=status.HTTP_400_BAD_REQUEST, 
    detail="Invalid Credentials"
)

AlreadyRegisteredException = HTTPException(
    status_code=status.HTTP_400_BAD_REQUEST, 
    detail="Username already registered"
)

EmailAlreadyExist = HTTPException(
    status_code=status.HTTP_400_BAD_REQUEST, 
    detail="Email already registered"
)

ProjectNotFound = HTTPException(
    status_code=status.HTTP_400_BAD_REQUEST, 
    detail="Given project not found"
)

ProjectForbidden = HTTPException(
    status_code=status.HTTP_403_FORBIDDEN, 
        detail="Not Authorized to use this project"
)

ForbiddenRequest = HTTPException(
    status_code=status.HTTP_403_FORBIDDEN, 
        detail="Not Authorized to do this operation"
)