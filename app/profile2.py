import streamlit as st

st.markdown(
    """
<style>
.standard-text {
    font-size:50px;
}
</style>
""",
    unsafe_allow_html=True,
)


def app(user_tier, tier_charges):
    # st.markdown("#### Your Wallet")
    left_column, right_column = st.columns([100, 100])
    left_column.write("Your NFT image for your rank is below:")
    # st.markdown('<p class="standard-text">Hello World !!</p>', unsafe_allow_html=True)
    left_column.image("image/tier2.png", width=250)
    left_column.write("Progress to Rank 3:")
    left_column.progress(10)

    right_column.write("Balance: 0.95 ETH")
    right_column.write("Current Rank: Rank 2")
    right_column.write(
        "Percentage you will pay to charities when paying non-whitelist companies: "
        + str(tier_charges[1])
        + "%."
    )
