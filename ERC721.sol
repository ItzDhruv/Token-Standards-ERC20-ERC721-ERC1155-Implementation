pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface ISubmission {
    struct Dhruv {
        address author;
        string line1;
        string line2;
        string line3;
    }

    function mintDhruv(
        string memory _line1,
        string memory _line2,
        string memory _line3
    ) external;

    function counter() external view returns (uint256);

    function shareDhruv(uint256 _id, address _to) external;

    function getMySharedDhruvs() external view returns (Dhruv[] memory);
}

contract DhruvNFT is ERC721, ISubmission {
    Dhruv[] public dhruvs;
    mapping(address => mapping(uint256 => bool)) public sharedDhruvs;
    uint256 public dhruvCounter;

    constructor() ERC721("DhruvNFT", "DHRUV") {
        dhruvCounter = 1;
    }

    function counter() external view override returns (uint256) {
        return dhruvCounter;
    }

    function mintDhruv(
        string memory _line1,
        string memory _line2,
        string memory _line3
    ) external override {
        string[3] memory dhruvsStrings = [_line1, _line2, _line3];
        for (uint256 li = 0; li < dhruvsStrings.length; li++) {
            string memory newLine = dhruvsStrings[li];
            for (uint256 i = 0; i < dhruvs.length; i++) {
                Dhruv memory existingDhruv = dhruvs[i];
                string[3] memory existingDhruvStrings = [
                    existingDhruv.line1,
                    existingDhruv.line2,
                    existingDhruv.line3
                ];
                for (uint256 eHsi = 0; eHsi < 3; eHsi++) {
                    string memory existingDhruvString = existingDhruvStrings[
                        eHsi
                    ];
                    if (
                        keccak256(abi.encodePacked(existingDhruvString)) ==
                        keccak256(abi.encodePacked(newLine))
                    ) {
                        revert DhruvNotUnique();
                    }
                }
            }
        }

        _safeMint(msg.sender, dhruvCounter);
        dhruvs.push(Dhruv(msg.sender, _line1, _line2, _line3));
        dhruvCounter++;
    }

    function shareDhruv(uint256 _id, address _to) external override {
        require(_id > 0 && _id <= dhruvCounter, "Invalid dhruv ID");

        Dhruv memory dhruvToShare = dhruvs[_id - 1];
        require(dhruvToShare.author == msg.sender, "NotYourDhruv");

        sharedDhruvs[_to][_id] = true;
    }

    function getMySharedDhruvs()
        external
        view
        override
        returns (Dhruv[] memory)
    {
        uint256 sharedDhruvCount;
        for (uint256 i = 0; i < dhruvs.length; i++) {
            if (sharedDhruvs[msg.sender][i + 1]) {
                sharedDhruvCount++;
            }
        }

        Dhruv[] memory result = new Dhruv[](sharedDhruvCount);
        uint256 currentIndex;
        for (uint256 i = 0; i < dhruvs.length; i++) {
            if (sharedDhruvs[msg.sender][i + 1]) {
                result[currentIndex] = dhruvs[i];
                currentIndex++;
            }
        }

        if (sharedDhruvCount == 0) {
            revert NoDhruvsShared();
        }

        return result;
    }

    error DhruvNotUnique();
    error NotYourDhruv();
    error NoDhruvsShared();
}

