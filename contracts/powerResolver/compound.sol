pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

interface CTokenInterface {
    function exchangeRateStored() external view returns (uint);
    function borrowBalanceStored(address) external view returns (uint);

    function balanceOf(address) external view returns (uint);
}

interface ListInterface {
    function accounts() external view returns (uint64);
    function accountID(address) external view returns (uint64);
    function accountAddr(uint64) external view returns (address);
}

contract Helpers {

    struct CompData {
        uint balanceOfUser;
        uint borrowBalanceStoredUser;
    }
    struct data {
        address user;
        CompData[] tokensData;
    }
    
     struct datas {
        CompData[] tokensData;
    }
}


contract Resolver is Helpers {
    
    function getDSAWallets(uint start, uint end) public view returns(address[] memory) {
        assert(start < end);
        ListInterface list = ListInterface(0x4c8a1BEb8a87765788946D6B19C6C6355194AbEb);
        uint totalAccounts = uint(list.accounts());
        end = totalAccounts < end ? totalAccounts : end;
        uint len = end - start;
        address[] memory wallets = new address[](len);
        for (uint i = start; i < end; i++) {
            wallets[i] = list.accountAddr(uint64(i+1));
        }
        return wallets;
    }

    function getCompoundData(address owner, address[] memory cAddress) public view returns (CompData[] memory) {
        CompData[] memory tokensData = new CompData[](cAddress.length);
        for (uint i = 0; i < cAddress.length; i++) {
            CTokenInterface cToken = CTokenInterface(cAddress[i]);
            tokensData[i] = CompData(
                cToken.balanceOf(owner),
                cToken.borrowBalanceStored(owner)
            );
        }

        return tokensData;
    }
    
    function getCompoundDataByToken(address[] memory owners, address cAddress) public view returns (CompData[] memory) {
        CompData[] memory tokensData = new CompData[](owners.length);
        CTokenInterface cToken = CTokenInterface(cAddress);
        for (uint i = 0; i < owners.length; i++) {
            tokensData[i] = CompData(
                cToken.balanceOf(owners[i]),
                cToken.borrowBalanceStored(owners[i])
            );
        }

        return tokensData;
    }

    function getPositionByAddress(
        address[] memory owners,
        address[] memory cAddress
    )
        public
        view
        returns (datas[] memory)
    {
        datas[] memory _data = new datas[](cAddress.length);
        for (uint i = 0; i < cAddress.length; i++) {
            _data[i] = datas(
                getCompoundDataByToken(owners, cAddress[i])
            );
        }
        return _data;
    }

    function getPositionByAccountIds(
        uint start,
        uint end,
        address[] memory cAddress
    )
        public
        view
        returns (datas[] memory)
    {
        address[] owners = getDSAWallets(start, end);
        datas[] memory _data = new datas[](cAddress.length);
        for (uint i = 0; i < cAddress.length; i++) {
            _data[i] = datas(
                getCompoundDataByToken(owners, cAddress[i])
            );
        }
        return _data;
    }

}
