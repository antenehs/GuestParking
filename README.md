![image](https://user-images.githubusercontent.com/3033385/203466716-7643895e-1947-4441-ab6e-f40d77ab03ae.png)

# GuestParking

Guest parking tries to do what guest parking registration websites can do easily, but almost everytime don't. None of the guest parking registration websites I used like "ParkingBadge" and "Register2Park", don't have the ability to save a recurring guest's info and auto register them next time. 

GuestParking automatically saves entered user info the first time and makes it easy to fill the form the next time. It does this by some java script magic on the website. So unfortunately, the scrapping code is broken for more time than it works. But that time it works, you know how it feels. 

Currently the only two supported guest parking websites are [ParkingBadge](https://parkingbadge.com), [Parking Permit of America](http://www.parkingpermitsofamerica.com/PermitRegistration.aspx) and [Register2Park](https://www.register2park.com).

To Add your own, add a class confirming to `PageManager` protocol. See `Register2ParkPageManager` and `ParkingBadgePageManager` for example. 

![image](https://user-images.githubusercontent.com/3033385/203467279-a7f03f62-bc80-4551-b616-5c1fe2c54e12.png)

![image](https://user-images.githubusercontent.com/3033385/203467288-f5cf20af-e038-43b7-b085-5a5d157d935e.png)


